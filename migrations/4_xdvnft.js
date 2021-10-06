const BigNumber = require('bignumber.js')
const fs = require('fs')
const XDVNFT = artifacts.require('XDVNFT')
const DAI = artifacts.require('DAI')

const ContractImportBuilder = require('../contract-import-builder')

module.exports = async (deployer, network, accounts) => {
    const builder = new ContractImportBuilder();
    const path = `${__dirname}/../abi-export/xdv.js`;

    builder.setOutput(path);
    builder.onWrite = (output) => {
        fs.writeFileSync(path, output);
    };
    let xdvnft;
    let stableCoinAddress = "0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d";
    let dai;

    if (network === "bsc") {
      stableCoinAddress = "0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d";
    }
    else{
      await deployer.deploy(DAI);
      dai = await DAI.deployed();
      stableCoinAddress = dai.address;
    }
    // else {

    await deployer.deploy(XDVNFT, "XDVNFT","XDVNFT", stableCoinAddress);

    xdvnft = await XDVNFT.deployed();
    await xdvnft.setServiceFeeForContract(new BigNumber(1 * 1e18));
    const fee_bn = new BigNumber(5 * 1e18);
    await dai.mint(accounts[0],fee_bn);

    await xdvnft.mint(  accounts[0], "bafyreicztwstn4ujtsnabjabn3hj7mvbhsgrvefbh37ddnx4w2pvghvsfm")
    
    // builder.addContract(
    //   'DAI',
    //   dai,
    //   stableCoinAddress,
    //   network
    // );

    builder.addContract(
      'XDVNFT',
      xdvnft,
      xdvnft.address,
      network
    );
};
