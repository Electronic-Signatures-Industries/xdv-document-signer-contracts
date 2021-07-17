const BigNumber = require('bignumber.js');
const fs = require('fs');
const DAI = artifacts.require('DAI');
const XDVDocumentAnchoring = artifacts.require('XDVDocumentAnchoring');

const ContractImportBuilder = require('../contract-import-builder');

module.exports = async (deployer, network, accounts) => {
    const builder = new ContractImportBuilder();
    const path = `${__dirname}/../abi-export/xdv.js`;

    builder.setOutput(path);
    builder.onWrite = (output) => {
        fs.writeFileSync(path, output);
    };
    let xdvDocumentAnchoring;
    let daiaddress = "";
    let dai;

    if (network === "bsc") {
      daiaddress = "0x1af3f329e8be154074d8769d1ffa4ee058b1dbc3";
    }
    else{
     // await deployer.deploy(DAI);
     // dai = await DAI.deployed();
     // testnet
      daiaddress = `0xec5dcb5dbf4b114c9d0f65bccab49ec54f6a0867`;
    }
    // else {

    await deployer.deploy(XDVDocumentAnchoring, daiaddress);

    xdvDocumentAnchoring = await XDVDocumentAnchoring.deployed();
    await xdvDocumentAnchoring.setProtocolConfig(new BigNumber(0.5 * 1e18));
    /*const fee_bn = new BigNumber(5 * 1e18);
    await dai.mint(accounts[0],fee_bn);*/

    builder.addContract(
      'XDVDocumentAnchoring',
      xdvDocumentAnchoring,
      xdvDocumentAnchoring.address,
      network
    );
};