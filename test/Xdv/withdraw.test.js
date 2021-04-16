const { assert } = require("chai");
const Bluebird = require("bluebird");
const BN = require("bn.js");
const TestUSDC = artifacts.require("USDC");
const XDV = artifacts.require("XDV");

contract("XDV: Withdraw Balance", (accounts) => {
  const amountToWithdraw = new BN(web3.utils.toWei("1337"));
  const contractOwner = accounts[0];
  const receiverAccount = accounts[3];
  let xdvContract;
  let erc20Contract;

  before(async () => {
    ({ erc20Contract, xdvContract } = await Bluebird.props({
      erc20Contract: TestUSDC.deployed(),
      xdvContract: XDV.deployed(),
    }));
  });

  // Add some money to the xdvContract
  beforeEach(async () => {
    await erc20Contract.mint(xdvContract.address, amountToWithdraw);
  });

  it("should withdaw tokens stored for the contract", async () => {
    const receiverBalance1 = await erc20Contract.balanceOf(receiverAccount);

    await xdvContract.withdrawBalance(receiverAccount, { from: contractOwner });

    const receiverBalance2 = await erc20Contract.balanceOf(receiverAccount);
    const expectedBalance = receiverBalance1.add(amountToWithdraw);
    assert(
      expectedBalance.eq(receiverBalance2),
      "Receiver account must have the expected balance"
    );
  });

  it("should NOT withdaw if the sender is not the Contract Owner", async () => {
    const receiverBalance1 = await erc20Contract.balanceOf(receiverAccount);

    try {
      await xdvContract.withdrawBalance(receiverAccount, { from: accounts[1] });
      assert.fail("Should have failed");
    } catch (e) {
      assert.equal(e.reason, "Ownable: caller is not the owner");

      const receiverBalance2 = await erc20Contract.balanceOf(receiverAccount);
      assert(
        receiverBalance1.eq(receiverBalance2),
        "Receiver account must have the expected balance"
      );
    }
  });
});
