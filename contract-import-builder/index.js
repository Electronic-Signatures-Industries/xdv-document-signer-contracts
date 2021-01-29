const fs = require('fs');

const _networks = {
  ropsten: 3,
  rinkeby: 4,
  kovan: 42,
  mainnet: 1,
};

module.exports = class ContractImportBuilder {
  constructor(network) {
    this.network = network;
    this.abiPath = '../abi-export';
    this.addressPath = `../address-export/${network}/`;
    this.filename = '';
    this.abi = {
      VERSION: '1.0.0',
    };
    this.address = {
      VERSION: '1.0.0',
    };
  }

  setPath = (path) => {
    this.path = path;
  };

  setFilename = (filename) => {
    this.filename = filename;
  };

  write = () => {
    // Write the abi export file
    fs.writeFileSync(
      `${__dirname}/${this.abiPath}/${this.filename}.json`,
      JSON.stringify(this.abi)
    );
    // Check if the network folder exists if not make it
    const addressNetworkDir = `${__dirname}/${this.addressPath}`;
    if (!fs.existsSync(addressNetworkDir)) {
      fs.mkdirSync(addressNetworkDir);
    }
    // Write the address file
    fs.writeFileSync(
      `${addressNetworkDir}/${this.filename}.json`,
      JSON.stringify(this.address)
    );
  };

  addContract = (name, abi, address) => {
    this.abi[name] = {
      raw: {
        abi: abi.abi,
      },
    };
    if (address) {
      this.address[name] = {
        address,
      };
    }
    this.write();
  };
};
