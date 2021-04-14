const { assert } = require("chai");
const XDVController = artifacts.require("XDVController");

contract("XDVController: ERC-1271", (_accounts) => {
  let controllerContract;

  /*
   * TODO: Find a way to generate this on-the-fly with Truffle's Web3 without leaking private keys.
   * Data generated with:
   * const { messageHash, signature } = await web3.eth.accounts.sign("Test Message", PRIVATE_KEY);
   */
  const messageHash =
    "0xd81bbffb92157b72ceae3da72eb8224976ba42a49621822789edb0735a0e0395";
  // Signed with `accounts[0]`, the contract's owner().
  const correctSignature =
    "0xed2e3b6d16886fe85b638062c5135110f5de578a1ac6dd431bc99ebfd9c4c7b9190fd9f7223516a1e7f30da66e2a7cea68b68e5588d44b4e9b829d1cabdc1aa71c";
  // Signed with `accounts[1]`, which is NOT the contract's owner()
  const wrongSignature =
    "0x10408bcc64d326d681d10b8661e9e5a710a48eb3b7a059a38cb24771a08e6bc964cbea87851ce9b849dfb300bb9e0e053e20d3b53382092116f3389c9c600d341c";

  before(async () => {
    controllerContract = await XDVController.deployed();
    assert.isNotNull(controllerContract, "Contract must exist");

    const owner = await controllerContract.owner();
    assert.equal(
      owner,
      "0xA83B070a68336811e9265fbEc6d49B98538F61EA",
      "Owner is different than expected. The tests will fail"
    );
  });

  it("should return the Magic Number when the signer is the owner", async () => {
    const magicNumber = await controllerContract.isValidSignature(
      messageHash,
      correctSignature
    );
    assert.equal("0x1626ba7e", magicNumber);
  });

  it("should return false when the signer is not the owner", async () => {
    const magicNumber = await controllerContract.isValidSignature(
      messageHash,
      wrongSignature
    );
    assert.equal("0x00000000", magicNumber);
  });
});
