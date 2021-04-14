const { assert } = require("chai");
const Bluebird = require("bluebird");
const TestUSDC = artifacts.require("USDC");
const XDV = artifacts.require("XDV");
const XDVController = artifacts.require("XDVController");

contract("XDVController: Minting and Burning", (accounts) => {
  const accountNotary = accounts[0];
  const accountDataProvider = accounts[1];
  const accountTokenOwner = accounts[2];
  let controllerContract;
  let erc20Contract;
  let xdvContract;
  let requestId;

  before(async () => {
    [erc20Contract, xdvContract, controllerContract] = await Bluebird.all([
      TestUSDC.deployed(),
      XDV.deployed(),
      XDVController.deployed(),
    ]);

    // Starting Document
    const result = await controllerContract.requestDataProviderService(
      "did:test:1",
      accountDataProvider,
      `did:eth:${accountNotary}`,
      "ipfs://test",
      "Lorem Ipsum"
    );
    requestId = result.receipt.logs[0].args.id;

    // Mint erc20s and approve transfer of them
    await Bluebird.all([
      erc20Contract.mint(accountTokenOwner, web3.utils.toWei("200")),
      erc20Contract.approve(xdvContract.address, web3.utils.unitMap.tether, {
        from: accountTokenOwner,
      }),
    ]);
  });

  describe("Golden Path", () => {
    let tokenId;
    let feeForContract;
    let feeForPaymentAddress;
    let startingClientBalance;
    let startingAddressBalance;
    let startingContractBalance;

    // Starting Values
    before(async () => {
      [
        startingClientBalance,
        startingContractBalance,
        startingAddressBalance,
        feeForPaymentAddress,
        feeForContract,
      ] = await Bluebird.all([
        erc20Contract.balanceOf(accountTokenOwner),
        erc20Contract.balanceOf(xdvContract.address),
        erc20Contract.balanceOf(accountNotary),
        xdvContract.serviceFeeForPaymentAddress(),
        xdvContract.serviceFeeForContract(),
      ]);
    });

    it("should mint the tokens", async () => {
      await controllerContract.mint(
        requestId,
        accountTokenOwner,
        accountNotary,
        "ipfs://test2"
      );

      const result = await xdvContract.getPastEvents("Transfer", {
        fromBlock: 0,
        toBlock: "latest",
      });

      tokenId = result[0].returnValues.tokenId;
      const { owner, balance } = await Bluebird.props({
        owner: xdvContract.ownerOf(tokenId),
        balance: xdvContract.balanceOf(accountTokenOwner),
      });
      assert.equal(owner, accountTokenOwner);
      assert.equal(balance, 1);
    });

    it("should burn and charge the account", async () => {
      // Burn the token
      const result = await xdvContract.burn(tokenId, {
        from: accountTokenOwner,
      });

      // Execution Results
      const event = result.logs.find((e) => e.event === "ServiceFeePaid");
      assert.isNotNull(event, "The ServiceFeePaid event must exist");
      const { args } = event;
      assert.equal(
        args.from,
        accountTokenOwner,
        "Should have come from NFT Owner"
      );
      assert.equal(
        args.paymentAddress,
        accountNotary,
        "Should sent the Fee to the correct address"
      );
      assert.equal(
        args.paidToContract.toString(),
        feeForContract.toString(),
        "Should Pay the Contract its correct share"
      );
      assert.equal(
        args.paidToPaymentAddress.toString(),
        feeForPaymentAddress.toString(),
        "Should Pay the Payment Address its Fee"
      );

      // New token Balances
      const {
        clientBalance,
        contractBalance,
        paymentAddressBalance,
      } = await Bluebird.props({
        contractBalance: erc20Contract.balanceOf(xdvContract.address),
        paymentAddressBalance: erc20Contract.balanceOf(accountNotary),
        clientBalance: erc20Contract.balanceOf(accountTokenOwner),
      });

      // Make sure the new balances are correct!
      const totalFeePaid = feeForContract.add(feeForPaymentAddress);
      assert.equal(
        clientBalance.toString(),
        startingClientBalance.sub(totalFeePaid).toString(),
        "The client's balance must have been reduced"
      );
      assert.equal(
        contractBalance.toString(),
        startingContractBalance.add(feeForContract).toString(),
        "The contract must have received tokens"
      );
      assert.equal(
        paymentAddressBalance.toString(),
        startingAddressBalance.add(feeForPaymentAddress).toString(),
        "The Payment Address must have received tokens"
      );
    });
  });
});
