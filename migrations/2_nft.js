const fs = require('fs');
const DocumentAnchoring = artifacts.require('DocumentAnchoring');
const NFTFactory = artifacts.require('NFTFactory');
const DAI = artifacts.require('DAI');


const ContractImportBuilder = require('../contract-import-builder');

module.exports = async (deployer, network, accounts) => {
  const builder = new ContractImportBuilder();
  const path = `${__dirname}/../abi-export/main.js`;

  builder.setOutput(path);
  builder.onWrite = (output) => {
    fs.writeFileSync(path, output);
  };
  let dai;
  let daiaddress = ""
  // if (network === "rinkeby") {
  daiaddress = "0xec5dcb5dbf4b114c9d0f65bccab49ec54f6a0867"
  // }
  // else {

  await deployer.deploy(DAI);
  dai = await DAI.deployed();
  //   daiaddress = dai.address
  // }
  await deployer.deploy(DocumentAnchoring);
  const documents = await DocumentAnchoring.deployed();

  await deployer.deploy(NFTFactory, daiaddress);
  const factory = await NFTFactory.deployed();

  builder.addContract(
    'DAI',
    dai,
    daiaddress,
    network
  );

  builder.addContract(
    'DocumentAnchoring',
    documents,
    documents.address,
    network
  );

  builder.addContract(
    'NFTFactory',
    factory,
    factory.address,
    network
  );
};
