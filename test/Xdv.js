// const assert = require("assert");
const Web3 = require('web3');
const web3 = new Web3();
const BigNumber = require('bignumber.js');
const { ethers } = require('ethers');
const { assert } = require('chai');

contract('XDVDocumentAnchoring', accounts => {
    let xdvDocumentAnchoring;
    let XDVDocumentAnchoring = artifacts.require('XDVDocumentAnchoring');
    let documents;

    contract('#documents', () => {
        before(async () => {
            documents = await XDVDocumentAnchoring.deployed();
        })
        describe('when creating a xdv document issuing provider', () => {
            xit('should add a new Document', async () => {
                const userDID = 'user DID';
                const res = await documents.addDocument(
                    userDID,
                    'document URI',
                    'any description'
                );

                console.log('test ',res.logs[0].args);
                const _id = res.logs[0].args.id.toString();
                const xdvDocAnchoring = await documents.minterDocumentAnchors(accounts[0],_id);

                assert.equal(await xdvDocAnchoring.user, accounts[0]);
                assert.equal(await xdvDocAnchoring.userDid, userDID);
            });
        });
    });
})