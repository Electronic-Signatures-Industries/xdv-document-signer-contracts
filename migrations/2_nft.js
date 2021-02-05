const BigNumber = require('bignumber.js');
const fs = require('fs');
const DocumentAnchoring = artifacts.require('DocumentAnchoring');
const NFTManager = artifacts.require('NFTManager');
const DAI = artifacts.require('DAI');
const NFTDocumentMinter = artifacts.require('NFTDocumentMinter');

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

  await deployer.deploy(NFTManager, daiaddress);
  const manager = await NFTManager.deployed();

  await deployer.deploy(NFTDocumentMinter, "XDV Document Token", "XDV", daiaddress);
  const datatoken = await NFTDocumentMinter.deployed();
  
  await manager.setProtocolFee(new BigNumber(5 * 1e18));
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
    'NFTManager',
    manager,
    manager.address,
    network
  );


  builder.addContract(
    'NFTDocumentMinter',
    datatoken,
    datatoken.address,
    network
  );  
};
