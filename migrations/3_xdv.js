const fs = require("fs");
const XDVDocumentAnchoring = artifacts.require("XDVDocumentAnchoring");

const ContractImportBuilder = require("../contract-import-builder");

module.exports = async (deployer, network, accounts) => {
  const builder = new ContractImportBuilder();
  const path = `${__dirname}/../abi-export/xdv.js`;

  builder.setOutput(path);
  builder.onWrite = (output) => {
    fs.writeFileSync(path, output);
  };

  await deployer.deploy(XDVDocumentAnchoring);
  const xdvDocumentAnchoring = await XDVDocumentAnchoring.deployed();

  builder.addContract(
    "XDVDocumentAnchoring",
    xdvDocumentAnchoring,
    xdvDocumentAnchoring.address,
    network
  );
};
