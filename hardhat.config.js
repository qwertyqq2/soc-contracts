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
      accounts: [process.env.PK_KEY4, process.env.PK_KEY3, process.env.PK_KEY2],
    },
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${process.env.GOERLI_RPC}`,
      accounts: [process.env.PK_KEY2, process.env.PK_KEY3, process.env.PK_KEY4, process.env.PK_KEY1],
    },
    Localhost8545: {
      url: "http://127.0.0.1:8545",
      accounts: [`45c5777059587bd382ac973b3eca8e21abaa9e19e1f12ef05ee67b2ee7f6aeed`,
        `ae7404923a4077dec8d296d025245a72bd5b5f4422d3cae5a21a9ee37b0cbfa5`,
        `9a59128d42014ea2050c92001e8a894e855c6358b89fb9a24fbf651c04e2aa74`]
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