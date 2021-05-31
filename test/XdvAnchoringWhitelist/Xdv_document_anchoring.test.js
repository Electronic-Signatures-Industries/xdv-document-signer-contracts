const { assert } = require('chai');

contract('XDVDocumentAnchoring: Add Document', accounts => {
    let xdvDocumentAnchoring;
    let XDVDocumentAnchoring = artifacts.require('XDVDocumentAnchoring');
    let documents;

    // contract('documents', () => {
        before(async () => {
            documents = await XDVDocumentAnchoring.deployed();
        })
        describe('when creating a xdv document issuing provider', () => {
            it('should add a new Document', async () => {
                const userDID = 'user DID';
                const res = await documents.addDocument(
                    userDID,
                    'document URI',
                    'any description',
                    [
                        accounts[1],
                        accounts[2],
                    ],
                    1
                );

                console.log('test ',res.logs[0].args);
                const _id = res.logs[0].args.id.toString();
                const xdvDocAnchoring = await documents.minterDocumentAnchors(accounts[0],_id);

                assert.equal(await xdvDocAnchoring.user, accounts[0], 'not the same user acc');
                assert.equal(await xdvDocAnchoring.userDid, userDID, 'userDID is different');
            });
        });
    
})

//2 peers
//When adding a new document

// // This script is a copy of the "Golden Path" test
// async function script() {
//   const accounts = await web3.eth.getAccounts();

//   const accountNotary = accounts[0];
//   const accountDataProvider = accounts[1];
//   const accountTokenOwner = accounts[2];

//   const [erc20Contract, xdvContract] = await Bluebird.all([
//     // MockCoin.deployed(),
//     // XDVToken.deployed(),
//     XDVDocumentAnchoring.deployed()
//   ]);

//   // Starting Document
//   const documentResult = await xdvContract.requestDataProviderService(
//     "did:test:1",
//     accountDataProvider,
//     `did:eth:${accountNotary}`,
//     "ipfs://test",
//     "Lorem Ipsum",
//   );
//   const requestId = documentResult.receipt.logs[0].args.id;
//   console.log(`Document Anchored: ID: ${requestId}`);

//   // Mint the token
//   const mintResult = await xdvContract.mint(
//     requestId,
//     accountTokenOwner,
//     accountNotary,
//     "ipfs://test2",
//   );

//   const { tokenId } = mintResult.logs.find((e) => e.event === "Transfer").args;
//   console.log(`Token Minted. ID: ${tokenId.toString()}`);

//   // Mint erc20s and approve transfer of them
//   await Bluebird.all([
//     erc20Contract.mint(accountTokenOwner, web3.utils.toWei("200")),
//     erc20Contract.approve(xdvContract.address, web3.utils.unitMap.tether, {
//       from: accountTokenOwner,
//     }),
//   ]);

//   // Burn the token
//   const result2 = await xdvContract.burn(tokenId, {
//     from: accountTokenOwner,
//   });
//   const event = result2.logs.find((e) => e.event === "ServiceFeePaid");
//   console.log("Token Burned. ID: " + event.args.tokenId.toString());
// }

// module.exports = (callback) => {
//   script().then(callback);
// };
