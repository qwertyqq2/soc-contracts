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
  //defaultNetwork: "ganache",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [process.env.GOERLI_PRIVATE_KEY]
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