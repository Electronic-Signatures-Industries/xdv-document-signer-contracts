const fs = require('fs');
const DocumentAnchoring = artifacts.require('DocumentAnchoring');
const NFTFactory = artifacts.require('NFTFactory');
const TestDAI = artifacts.require('DAI');


const ContractImportBuilder = require('../contract-import-builder');

module.exports = async (deployer, network, accounts) => {
  const builder = new ContractImportBuilder();
  const path = `${__dirname}/../abi-export/main.js`;

  builder.setOutput(path);
  builder.onWrite = (output) => {
    fs.writeFileSync(path, output);
  };

  await deployer.deploy(TestDAI);
  const dai = await TestDAI.deployed();

  await deployer.deploy(DocumentAnchoring);
  const documents = await DocumentAnchoring.deployed();

  await deployer.deploy(NFTFactory, dai.address);
  const factory = await NFTFactory.deployed();

  builder.addContract(
    'TestDAI',
    dai,
    dai.address,
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
