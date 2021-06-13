const BigNumber = require('bignumber.js');
const fs = require('fs');
const MockCoin = artifacts.require('MockCoin');
const Klip = artifacts.require('KLIP');

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

  await deployer.deploy(MockCoin);
  usdc = await MockCoin.deployed();
  //   usdcaddress = usdc.address

  await deployer.deploy(Klip, usdc.address, accounts[0]);
  const datatoken = await Klip.deployed();


  const serviceFeeForContract = new BigNumber(1 * 1e17)
  const serviceFeeForPaymentAddress = new BigNumber(9 * 1e17)
  await datatoken.setServiceFee(serviceFeeForContract);
  await datatoken.setServiceRoyalty(serviceFeeForPaymentAddress);

  builder.addContract(
    'MockCoin',
    usdc,
    usdc.address,
    network
  );

  builder.addContract(
    'Klip',
    datatoken,
    datatoken.address,
    network
  );  
};
