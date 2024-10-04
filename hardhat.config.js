require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 500
      }
    }
  },
  networks: {
    sepolia: {
      url: "https://sepolia.infura.io/v3/2e73c435006e434bb69343838ceff296", // Replace with your Infura project ID or another Sepolia RPC URL
      accounts: ["ea2be3afcd4d420c5cd8fb704f9279ad692e348a39452b8f1551162e38eb455a"]
    }
  },
  etherscan: {
    apiKey: "W1VID4Z2B18K4JIXBUGF9FVPYB3DHTHTIS"
  }
};
