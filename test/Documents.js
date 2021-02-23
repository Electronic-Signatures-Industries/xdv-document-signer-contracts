// const assert = require("assert");
const Web3 = require('web3');
const web3 = new Web3();
const BigNumber = require('bignumber.js');
const { ethers } = require('ethers');
const { assert } = require('chai');

contract('XDV NFT', accounts => {
  let usdc;
  let owner;
  let ctrl;
  let documents;
  let documentMinterAddress;
  let xdv;
  let DocumentAnchoring = artifacts.require('DocumentAnchoring');
  let TestUSDC = artifacts.require('USDC');
  let XDV = artifacts.require('XDV');
  let XDVController = artifacts.require('XDVController');
  contract('#xdv data token', () => {
    before(async () => {
      owner = accounts[0];
      xdv = await XDV.deployed();
      usdc = await TestUSDC.deployed();
      ctrl = await XDVController.deployed();
      documents = await DocumentAnchoring.deployed();
    });
    describe('when registering a document issuing provider', () => {
      it('should create a new entry', async () => {
        assert.equal(ctrl !== null, true);

        const res = await ctrl.registerMinter(
          accounts[1],
          "NOTARIO 9VNO - APOSTILLADO",
          "0x0a2Cd4F28357D59e9ff26B1683715201Ea53Cc3b",
          false,
          new BigNumber(20 * 10e18)
        );

        await xdv.setWhitelistedMinter(ctrl.address);

        documentMinterAddress = res.logs[0].args.minter;
      });
    });


    describe('when requesting minting from a document issuing provider', () => {
      it('should anchor document and add it to request list', async () => {
        assert.equal(ctrl !== null, true);

        await usdc.mint(
          accounts[2],
          new BigNumber(22 * 10e18)
        );

        // allowance
        await usdc.approve(
          ctrl.address,
          new BigNumber(22 * 10e18), {

          from: accounts[2]
        }
        );

        const res = await ctrl.requestDataProviderService(
          "did:ethr:" + accounts[1],
          accounts[1],
          "did:ethr:" + accounts[2],
          "https://ipfs.io/ipfs/xxxx",
          "Notariar", {
          from: accounts[2]
        }
        );

        const id = res.logs[0].args.id;

        const requestMintResult = await ctrl.mint(
          id,
          accounts[2],
          documentMinterAddress,
          `https://bobb.did.pa`, {
          from: accounts[1]
        }
        );

        const bal = await xdv.balanceOf(accounts[2]);
        assert.equal(bal, 1);

        await ctrl.burn(
          0,
          1,
          1, {
            from: accounts[2]
          }
        )
      });

      xit('should mint NFT issued by document issuing provider', async () => {
        assert.equal(ctrl !== null, true);

        const minter = await XDV.at(documentMinterAddress);
        assert.equal(await minter.symbol(), "NOT9APOST");

        const minted = await minter.mint(
          accounts[0],
          `https://bobb.did.pa/index.json`
        );

        assert.equal(minted.logs[0].event, 'Transfer');
      });
    });
    describe('when burning', () => {
      xit('should pay for  service', async () => {
        assert.equal(ctrl !== null, true);

        const res = await ctrl.createMinter(
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



        const minter = await XDV.at(documentMinterAddress);
        assert.equal(await minter.symbol(), "NOT9APOST");

        const minted = await minter.mint(
          accounts[0],
          `https://bobb.did.pa/index.json`
        );

        assert.equal(minted.logs[0].event, 'Transfer');

        await usdc.mint(
          accounts[1],
          new BigNumber(22 * 10e18)
        );

        // allowance
        await usdc.approve(
          documentMinterAddress,
          new BigNumber(22 * 10e18), {

          from: accounts[1]
        }
        );

        await minter.burn(
          minted.logs[0].args.tokenId, {
          from: accounts[1],
          value: new BigNumber(2.4 * 1e18)
        }
        );
      });

    });

  });
});
