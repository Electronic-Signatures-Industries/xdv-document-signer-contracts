const BigNumber = require('bignumber.js');
const fs = require('fs');
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
    let daiaddress = ""
    // if (network === "rinkeby") {
    daiaddress = "0xec5dcb5dbf4b114c9d0f65bccab49ec54f6a0867"
    // }
    // else {

    await deployer.deploy(XDVDocumentAnchoring);
    xdvDocumentAnchoring = await XDVDocumentAnchoring.deployed();
    builder.addContract(
      'XDVDocumentAnchoring',
      xdvDocumentAnchoring,
      daiaddress,
      network
    );
};