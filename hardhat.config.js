const { default: Ganache } = require("ganache");

require("@nomicfoundation/hardhat-toolbox");
require('solidity-coverage')
require("hardhat-gas-reporter");
require("@nomiclabs/hardhat-ganache");
require('dotenv').config();



module.exports = {
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  defaultNetwork: "hardhat",
  networks: {
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${process.env.MUMBAI_RPC}`,
      accounts: [process.env.PK_KEY1, process.env.PK_KEY2, process.env.PK_KEY3, process.env.PK_KEY4],
    },
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