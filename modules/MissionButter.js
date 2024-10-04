const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("MissionButter", (m) => {
  const marketFactory = m.contract("MarketFactory");

  return { marketFactory };
});
