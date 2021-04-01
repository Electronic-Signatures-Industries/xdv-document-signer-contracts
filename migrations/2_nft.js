const BigNumber = require('bignumber.js');
const fs = require('fs');
const DocumentAnchoring = artifacts.require('DocumentAnchoring');
const XDVController = artifacts.require('XDVController');
const USDC = artifacts.require('USDC');
const XDV = artifacts.require('XDV');

const ContractImportBuilder = require('../contract-import-builder');

module.exports = async (deployer, network, accounts) => {
  const builder = new ContractImportBuilder();
  const path = `${__dirname}/../abi-export/nft.js`;

  builder.setOutput(path);
  builder.onWrite = (output) => {
    fs.writeFileSync(path, output);
  };
  let usdc;
  let usdcaddress = ""
  // if (network === "rinkeby") {
  usdcaddress = "0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d";
  // }
  // else {

  await deployer.deploy(USDC);
  usdc = await USDC.deployed();
  //   usdcaddress = usdc.address

  await deployer.deploy(XDV, "XDV Document Token", "XDV", usdc.address);
  const datatoken = await XDV.deployed();

  await deployer.deploy(XDVController, usdc.address, datatoken.address);
  const manager = await XDVController.deployed();

  
  await datatoken.setProtocolFee(new BigNumber(1 * 1e18));
  builder.addContract(
    'USDC',
    usdc,
    usdc.address,
    network
  );


  builder.addContract(
    'XDVController',
    manager,
    manager.address,
    network
  );


  builder.addContract(
    'XDV',
    datatoken,
    datatoken.address,
    network
  );  
};
