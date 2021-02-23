const BigNumber = require('bignumber.js');
const fs = require('fs');
const USDC = artifacts.require('USDC');
const DIDPaymentService = artifacts.require('DIDPaymentService');

const ContractImportBuilder = require('../contract-import-builder');

module.exports = async (deployer, network, accounts) => {
    const builder = new ContractImportBuilder();
    const path = `${__dirname}/../abi-export/did.js`;

    builder.setOutput(path);
    builder.onWrite = (output) => {
        fs.writeFileSync(path, output);
    };
    let payments;
    let usdcaddress = "";
    let usdc;

    if (network === "bsc") {
      usdcaddress = "0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d";
    }
    else{
      await deployer.deploy(USDC);
      usdc = await USDC.deployed();
      usdcaddress = usdc.address;
    }
    // else {

    await deployer.deploy(DIDPaymentService, usdcaddress);

    payments = await DIDPaymentService.deployed();
    await payments.setProtocolConfig(new BigNumber(9.5 * 1e18));
    /*const fee_bn = new BigNumber(5 * 1e18);
    await usdc.mint(accounts[0],fee_bn);*/

    builder.addContract(
      'USDC',
      usdc,
      usdcaddress,
      network
    );

    builder.addContract(
      'DIDPaymentService',
      payments,
      payments.address,
      network
    );
};