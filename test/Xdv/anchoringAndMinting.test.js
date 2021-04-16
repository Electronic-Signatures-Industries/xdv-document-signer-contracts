const { BigNumber } = require("bignumber.js");
const { assert } = require("chai");
const Bluebird = require("bluebird");
const TestUSDC = artifacts.require("USDC");
const XDV = artifacts.require("XDV");
const XDVController = artifacts.require("XDVController");

contract("XDV: Anchoring and Minting", (accounts) => {
  let erc20Contract;
  let controllerContract;
  let documentMinterAddress;
  let xdvContract;

  // Initialize the contracts and make sure they exist
  before(async () => {
    ({ controllerContract, xdvContract, erc20Contract } = await Bluebird.props({
      xdvContract: XDV.deployed(),
      erc20Contract: TestUSDC.deployed(),
      controllerContract: XDVController.deployed(),
    }));
  });

  describe("when registering a document issuing provider", () => {
    it("should create a new entry", async () => {
      const res = await controllerContract.registerMinter(
        "NOTARIO 9VNO - APOSTILLADO",
        "0x0a2Cd4F28357D59e9ff26B1683715201Ea53Cc3b",
        false,
        new BigNumber(20 * 10e18),
        {
          from: accounts[1],
        }
      );

      documentMinterAddress = res.logs[0].args.minter;
      assert.strictEqual(documentMinterAddress, accounts[1]);
    });
  });

  describe("when requesting minting from a document issuing provider", () => {
    let requestId;

    // Add some cash to the contracts
    before(async () => {
      const usdcAmount = new BigNumber(22 * 10e18);
      const recipentAddresses = [
        controllerContract.address,
        xdvContract.address,
      ];

      await erc20Contract.mint(
        accounts[2],
        usdcAmount.times(recipentAddresses.length)
      );
      const coroutines = recipentAddresses.map((addr) =>
        erc20Contract.approve(addr, usdcAmount, { from: accounts[2] })
      );
      await Bluebird.all(coroutines);
    });

    it("should anchor document and add it to request list", async () => {
      const minterAccount = accounts[1];
      const senderAccount = accounts[2];

      const res = await controllerContract.requestDataProviderService(
        `did:ethr:${minterAccount}`,
        minterAccount,
        `did:ethr:${senderAccount}`,
        "https://ipfs.io/ipfs/xxxx",
        "Notariar",
        {
          from: senderAccount,
        }
      );

      requestId = res.logs[0].args.id;
      assert.equal(requestId, 0);

      await controllerContract.mint(
        requestId,
        senderAccount,
        minterAccount,
        `https://bobb.did.pa`,
        {
          from: minterAccount,
        }
      );

      const bal = await xdvContract.balanceOf(senderAccount);
      assert.equal(bal, 1);
    });
  });
});
