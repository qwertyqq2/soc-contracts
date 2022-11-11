require("@nomicfoundation/hardhat-toolbox");
require('solidity-coverage')
require('@openzeppelin/hardhat-upgrades');
require("hardhat-gas-reporter");
require('dotenv').config();


module.exports = {
  solidity: {
    version: '0.8.7',
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
    outputFile: "gas-report.txt",
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "RUB",
    noColors: true,
    coinmarketcap: process.env.COIN_MARKETCAP_API_KEY || "",
    token: "MATIC"
  }
}