require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy")
require("@nomiclabs/hardhat-ethers")
require("solidity-coverage")

module.exports = {
  solidity: {
    version: "0.8.18",
    optimizer: {
      enabled: true,
      runs: 10000,
      // qwert
    }
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    tester: {
      default: 7
    }
  },
  defaultNetwork: "hardhat",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545/",
      chainId: 31337,
      blockConfirmations: 1
    },
    // sapoila: {
    //   url: sapoila_rpc,
    //   chainId: 11155111,
    //   blockConfirmations: 1,
    //   accounts: [ privateKey ] 
    // },
    // ganache: {
    //   url: ganache_rpc,
    //   chainId: 5777,
    //   blockConfirmations: 1 
    // }
  },
  mocha : {
    timeOut: 60000
  }
};

