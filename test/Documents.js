// const assert = require("assert");
const Web3 = require('web3');
const web3 = new Web3();
const BigNumber = require('bignumber.js');
const { ethers } = require('ethers');
const { assert } = require('chai');

contract('NFTFactory', accounts => {
  let dai;
  let owner;
  let nftFactory;
  let documents;
  let documentMinterAddress;
  let DocumentAnchoring = artifacts.require('DocumentAnchoring');
  let TestDAI = artifacts.require('DAI');
  let DocumentMinter = artifacts.require('NFTDocumentMinter');
  let NFTFactory = artifacts.require('NFTFactory');
  contract('#documents', () => {
    before(async () => {
      owner = accounts[0];
      dai = await TestDAI.deployed();
      nftFactory = await NFTFactory.deployed();
      documents = await DocumentAnchoring.deployed();
    });
    describe('when creating a document issuing provider', () => {
      it('should create a new NFT', async () => {
        assert.equal(nftFactory !== null, true);

        const res = await nftFactory.createMinter(
          "NOTARIO 9VNO - APOSTILLADO",
          "NOT9APOST",
          "0x0a2Cd4F28357D59e9ff26B1683715201Ea53Cc3b",
          false,
          new BigNumber(20 * 10e18)
        );

        const nftAddress = res.logs[0].args.minterAddress;
        const minter = await DocumentMinter.at(nftAddress);
        assert.equal(await minter.symbol(), "NOT9APOST");
      });
    });


    describe('when requesting minting from a document issuing provider', () => {
      it('should anchor document and add it to request list', async () => {
        assert.equal(nftFactory !== null, true);

        const res = await nftFactory.createMinter(
          "NOTARIO 9VNO - APOSTILLADO",
          "NOT9APOST",
          "0x0a2Cd4F28357D59e9ff26B1683715201Ea53Cc3b",
          false,
          new BigNumber(20 * 10e18)
        );

        documentMinterAddress = res.logs[0].args.minterAddress;

        const requestMintResult = await documents.requestMint(
          documentMinterAddress,
          `did:ethr:${documentMinterAddress}`,
          `did:ethr:${accounts[1]}`,
          false,
          `https://bobb.did.pa`, {
          from: accounts[1]
        }
        );
        assert.equal('https://bobb.did.pa', requestMintResult.logs[0].args.tokenURI);
      });

      it('should mint NFT issued by document issuing provider', async () => {
        assert.equal(nftFactory !== null, true);

        const minter = await DocumentMinter.at(documentMinterAddress);
        assert.equal(await minter.symbol(), "NOT9APOST");

        const minted = await minter.mint(
          accounts[0],
          `https://bobb.did.pa/index.json`
        );

        assert.equal(minted.logs[0].event, 'Transfer');
      });
    });
    describe('when burning', () => {
      it('should pay for  service', async () => {
        assert.equal(nftFactory !== null, true);

        const res = await nftFactory.createMinter(
          "NOTARIO 9VNO - APOSTILLADO",
          "NOT9APOST",
          "0x0a2Cd4F28357D59e9ff26B1683715201Ea53Cc3b",

          false,
          new BigNumber(2 * 1e18)
        );

        documentMinterAddress = res.logs[0].args.minterAddress;

        const requestMintResult = await documents.requestMint(
          documentMinterAddress,
          `did:ethr:${documentMinterAddress}`,
          `did:ethr:${accounts[1]}`,
          false,
          `https://bobb.did.pa`, {
          from: accounts[1]
        }
        );
        assert.equal('https://bobb.did.pa', requestMintResult.logs[0].args.tokenURI);



        const minter = await DocumentMinter.at(documentMinterAddress);
        assert.equal(await minter.symbol(), "NOT9APOST");

        const minted = await minter.mint(
          accounts[0],
          `https://bobb.did.pa/index.json`
        );

        assert.equal(minted.logs[0].event, 'Transfer');

        await dai.mint(
          accounts[1],
          new BigNumber(22 * 10e18)
        );

        // allowance
        await dai.approve(
          documentMinterAddress,
          new BigNumber(22 * 10e18), {

          from: accounts[1]
        }
        );

        await minter.burn(
          minted.logs[0].args.tokenId, {
          from: accounts[1],
          value: new BigNumber(2.4  * 1e18)
        }
        );
      });

    });

  });
});
