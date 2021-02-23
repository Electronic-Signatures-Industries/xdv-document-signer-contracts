// const assert = require("assert");
const Web3 = require('web3');
const web3 = new Web3();
const BigNumber = require('bignumber.js');
const { ethers } = require('ethers');
const { assert, expect } = require('chai');

contract('DID', accounts => {
  let usdc;
  let owner;
  let ctrl;
  let payments;
  let documentMinterAddress;
  let xdv;
  let DIDPaymentService = artifacts.require('DIDPaymentService');
  let TestUSDC = artifacts.require('USDC');
  let XDV = artifacts.require('XDV');
  let XDVController = artifacts.require('XDVController');
  contract('#did payment service', () => {
    before(async () => {
      owner = accounts[0];
      xdv = await XDV.deployed();
      usdc = await TestUSDC.deployed();
      ctrl = await XDVController.deployed();
      payments = await DIDPaymentService.deployed();
    });


    describe('when paying for KYC', () => {
      it('should verify payment', async () => {
        assert.equal(ctrl !== null, true);

        await usdc.mint(
          accounts[3],
          new BigNumber(22 * 10e18)
        );

        // allowance
        await usdc.approve(
          payments.address,
          new BigNumber(22 * 10e18), {

          from: accounts[3]
        }
        );

        const res = await payments.payKYCService({
          from: accounts[3]
        }

        );

        const isPaymentValid = await payments.verifyPayment({
          from: accounts[3]
        });
        expect(isPaymentValid).equal(true);
      });
    });

  });
});
