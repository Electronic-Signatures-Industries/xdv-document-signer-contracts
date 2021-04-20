const { assert } = require("chai");
let XDVDocumentAnchoring = artifacts.require("XDVDocumentAnchoring");

contract("XDVDocumentAnchoring", (accounts) => {
  let documentContract;

  before(async () => {
    documentContract = await XDVDocumentAnchoring.deployed();
  });

  it("should anchor a new document, if called by owner", async () => {
    const res = await documentContract.addDocument(
      "user DID",
      "ipfs://test",
      "any description",
      { from: accounts[0] }
    );

    const { id } = res.logs[0].args;
    const result = await documentContract.minterDocumentAnchors(
      accounts[0],
      id
    );

    assert.equal(result.user, accounts[0]);
    assert.equal(result.userDid, "user DID");
    assert.equal(result.documentURI, "ipfs://test");
    assert.equal(result.description, "any description");
  });
});
