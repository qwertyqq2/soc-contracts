require("@nomicfoundation/hardhat-toolbox");
require('solidity-coverage')
require('@openzeppelin/hardhat-upgrades');


module.exports = {
  solidity: {
    version: '0.8.13',
    settings: {
      optimizer: {
        enabled: true,
        runs: 100000000,
      },
    },
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    }
  },
  gasReporter: {
    enabled: false,
    currency: 'USD',
  },
}