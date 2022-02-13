require("@nomiclabs/hardhat-waffle")
const fs = require('fs')
const privateKey = process.env.PRIVATE_KEY;

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337
    },
//  mumbai: {
//    url: "https://rpc-mumbai.maticvigil.com",
//    accounts: [privateKey]
//  }
  },
  solidity: {
    version: "0.8.11",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}