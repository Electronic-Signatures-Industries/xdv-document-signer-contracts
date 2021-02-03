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
  let dai;
  let daiaddress =""
if  (network ==="rinkeby")
{
  daiaddress = "0xxxxxxx"
}
else {

  await deployer.deploy(TestDAI);
  dai = await TestDAI.deployed();
  daiaddress = dai.address
}
  await deployer.deploy(DocumentAnchoring);
  const documents = await DocumentAnchoring.deployed();

  await deployer.deploy(NFTFactory, daiaddress);
  const factory = await NFTFactory.deployed();

  builder.addContract(
    'TestDAI',
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
