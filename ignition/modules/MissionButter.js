const {buildModule} = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("MissionButter", (m) => {

  const realityETHAddress = "0xaf33DcB6E8c5c4D9dDF579f53031b514d19449CA";
  const oracle = m.contract("Oracle", [realityETHAddress]);

  // Deploy MarketFactory contract with Oracle address
  const marketFactory = m.contract("MarketFactory", [oracle]);

  // Create a new market
  const tokenName = "0x4578616d706c65546f6b656e0000000000000000000000000000000000000000";
  const market = m.call(marketFactory, "createMarket", [tokenName]);

  return {oracle, marketFactory, market};
});
