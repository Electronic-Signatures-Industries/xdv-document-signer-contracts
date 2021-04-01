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
          "NOTARIO 9VNO - APOSTILLADO",
          "0x0a2Cd4F28357D59e9ff26B1683715201Ea53Cc3b",
          false,
          new BigNumber(20 * 10e18), {
            from: accounts[1]
          }
        );


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
        assert.equal(id, 0);

        const requestMintResult = await ctrl.mint(
          id,
          accounts[2],
          accounts[1],
          `https://bobb.did.pa`, {
          from: accounts[1]
        }
        );

        const bal = await xdv.balanceOf(accounts[2]);
        assert.equal(bal, 1);


        await usdc.mint(
          accounts[2],
          new BigNumber(22 * 10e18)
        );

        // allowance
        await usdc.approve(
          xdv.address,
          new BigNumber(22 * 10e18), {

          from: accounts[2]
        }
        );
        
        await ctrl.burn(
          id,
          documentMinterAddress,
          1, {
            from: accounts[2]
          }
        )
      });


    });

  });
});
