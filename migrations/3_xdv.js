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

    await deployer.deploy(DAI);
    dai = await DAI.deployed();
    // if (network === "rinkeby") {
    daiaddress = "0xec5dcb5dbf4b114c9d0f65bccab49ec54f6a0867"
    // }
    // else {

    await deployer.deploy(XDVDocumentAnchoring, dai.address);

    xdvDocumentAnchoring = await XDVDocumentAnchoring.deployed();
    await xdvDocumentAnchoring.setProtocolConfig(new BigNumber(5 * 1e18));
    const fee_bn = new BigNumber(5 * 1e18);
    await dai.mint(accounts[0],fee_bn);

    builder.addContract(
      'DAI',
      dai,
      daiaddress,
      network
    );

    builder.addContract(
      'XDVDocumentAnchoring',
      xdvDocumentAnchoring,
      xdvDocumentAnchoring.address,
      network
    );
};