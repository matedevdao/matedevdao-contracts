import "dotenv/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomiclabs/hardhat-solhint";
import "hardhat-tracer";

import { HardhatUserConfig } from "hardhat/types";

let accounts;
if (process.env.PRIVATE_KEY) {
  accounts = [
    process.env.PRIVATE_KEY ||
    "0x0000000000000000000000000000000000000000000000000000000000000000",
  ];
} else {
  accounts = {
    mnemonic: process.env.MNEMONIC ||
      "test test test test test test test test test test test junk",
  };
}

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    klaytn: {
      url: "https://public-node-api.klaytnapi.com/v1/cypress",
      accounts,
      chainId: 8217,
      gasPrice: 250000000000,
    },
    "klaytn-testnet": {
      url: "https://public-node-api.klaytnapi.com/v1/baobab",
      accounts,
      chainId: 1001,
    },
  },
};

export default config;
