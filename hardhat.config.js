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
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${process.env.GOERLI_RPC}`,
      accounts: [process.env.PK_KEY1, process.env.PK_KEY2, process.env.PK_KEY3, process.env.PK_KEY4],
    },
    Localhost8545: {
      url: "http://127.0.0.1:8545",
      accounts: [`5bae0855da3bf651eaae1b0da8b065bed2709cdb22d15ed76b345d4d27e7dfe0`,
        `52e8b4adec4c5b8bafce01e5064c3ebcaa2afc3a30876351070ea275c89b17ed`,
        `6d5b31543ec2ea201a506d025fa1fd590a2ebe4e3b4395b8e663eafbbafc831c`]
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