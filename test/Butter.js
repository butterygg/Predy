const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Butter", function () {
  async function deployContractsFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const MarketFactory = await ethers.getContractFactory("MarketFactory");
    const marketFactory = await MarketFactory.deploy();
    await marketFactory.waitForDeployment();

    return { marketFactory, owner, addr1, addr2 };
  }

  describe("MarketFactory", function () {
    it("Should deploy MarketFactory successfully", async function () {
      const { marketFactory } = await loadFixture(deployContractsFixture);
      expect(await marketFactory.getAddress()).to.be.properAddress;
    });

    it("Should have an Oracle", async function () {
      const { marketFactory } = await loadFixture(deployContractsFixture);
      const oracleAddress = await marketFactory.oracle();
      expect(oracleAddress).to.be.properAddress;
    });

    it("Should create a new market", async function () {
      const { marketFactory } = await loadFixture(deployContractsFixture);
      const questionId = ethers.keccak256(ethers.toUtf8Bytes("Will it rain tomorrow?"));
      
      await expect(marketFactory.createMarket(questionId))
        .to.not.be.reverted;

      const marketAddress = await marketFactory.markets(questionId);
      expect(marketAddress).to.be.properAddress;
    });

    it("Should not allow creating a market with an existing questionId", async function () {
      const { marketFactory } = await loadFixture(deployContractsFixture);
      const questionId = ethers.keccak256(ethers.toUtf8Bytes("Will it rain tomorrow?"));
      
      await marketFactory.createMarket(questionId);
      await expect(marketFactory.createMarket(questionId))
        .to.be.revertedWith("Market already exists");
    });
  });

  describe("Market", function () {
    async function createMarketFixture() {
      const { marketFactory, owner, addr1, addr2 } = await deployContractsFixture();
      const questionId = ethers.keccak256(ethers.toUtf8Bytes("Will it rain tomorrow?"));
      await marketFactory.createMarket(questionId);
      const marketAddress = await marketFactory.markets(questionId);
      const Market = await ethers.getContractFactory("Market");
      const market = Market.attach(marketAddress);
      return { marketFactory, market, questionId, owner, addr1, addr2 };
    }

    it("Should have correct questionId", async function () {
      const { market, questionId } = await loadFixture(createMarketFixture);
      expect(await market.questionId()).to.equal(questionId);
    });

    it("Should have a MarketMaker", async function () {
      const { market } = await loadFixture(createMarketFixture);
      const marketMakerAddress = await market.marketMaker();
      expect(marketMakerAddress).to.be.properAddress;
    });

    it("Should allow resolving the market", async function () {
      const { market, owner } = await loadFixture(createMarketFixture);
      await expect(market.connect(owner).resolveMarket())
        .to.not.be.reverted;
      expect(await market.isResolved()).to.be.true;
    });
  });

  describe("MarketMaker", function () {
    async function setupMarketMakerFixture() {
      const { marketFactory, owner, addr1, addr2 } = await deployContractsFixture();
      const questionId = ethers.keccak256(ethers.toUtf8Bytes("Will it rain tomorrow?"));
      await marketFactory.createMarket(questionId);
      const marketAddress = await marketFactory.markets(questionId);
      const Market = await ethers.getContractFactory("Market");
      const market = Market.attach(marketAddress);
      const marketMakerAddress = await market.marketMaker();
      const MarketMaker = await ethers.getContractFactory("MarketMaker");
      const marketMaker = MarketMaker.attach(marketMakerAddress);
      return { marketMaker, owner, addr1, addr2 };
    }

    it("Should allow depositing", async function () {
      const { marketMaker, addr1 } = await loadFixture(setupMarketMakerFixture);
      const depositAmount = ethers.parseEther("1");
      await expect(marketMaker.connect(addr1).deposit({ value: depositAmount }))
        .to.changeEtherBalance(addr1, -depositAmount);
    });

    it("Should mint correct amount of tokens on deposit", async function () {
      const { marketMaker, addr1 } = await loadFixture(setupMarketMakerFixture);
      const depositAmount = ethers.parseEther("1");
      await marketMaker.connect(addr1).deposit({ value: depositAmount });

      const ConditionalToken = await ethers.getContractFactory("ConditionalToken");
      const passToken = ConditionalToken.attach(await marketMaker.passToken());
      const failToken = ConditionalToken.attach(await marketMaker.failToken());

      expect(await passToken.balanceOf(addr1.address)).to.equal(depositAmount);
      expect(await failToken.balanceOf(addr1.address)).to.equal(depositAmount);
    });

    it("Should allow withdrawing", async function () {
      const { marketMaker, addr1 } = await loadFixture(setupMarketMakerFixture);
      const depositAmount = ethers.parseEther("1");
      await marketMaker.connect(addr1).deposit({ value: depositAmount });

      await expect(marketMaker.connect(addr1).withdraw(depositAmount))
        .to.changeEtherBalance(addr1, depositAmount);
    });

    it("Should allow swapping tokens", async function () {
      const { marketMaker, addr1 } = await loadFixture(setupMarketMakerFixture);
      const depositAmount = ethers.parseEther("1");
      await marketMaker.connect(addr1).deposit({ value: depositAmount });

      const swapAmount = ethers.parseEther("0.5");
      await expect(marketMaker.connect(addr1).swap(true, swapAmount))
        .to.not.be.reverted;
    });
  });

  describe("ConditionalToken", function () {
    async function setupTokenFixture() {
      const [owner, addr1, addr2] = await ethers.getSigners();
      const ConditionalToken = await ethers.getContractFactory("ConditionalToken");
      const token = await ConditionalToken.deploy("Test Token", "TEST");
      await token.waitForDeployment();
      return { token, owner, addr1, addr2 };
    }

    it("Should have correct name and symbol", async function () {
      const { token } = await loadFixture(setupTokenFixture);
      expect(await token.name()).to.equal("Test Token");
      expect(await token.symbol()).to.equal("TEST");
    });

    it("Should allow minting tokens", async function () {
      const { token, addr1 } = await loadFixture(setupTokenFixture);
      const mintAmount = ethers.parseEther("100");
      await token.mint(addr1.address, mintAmount);
      expect(await token.balanceOf(addr1.address)).to.equal(mintAmount);
    });

    it("Should allow burning tokens", async function () {
      const { token, addr1 } = await loadFixture(setupTokenFixture);
      const mintAmount = ethers.parseEther("100");
      await token.mint(addr1.address, mintAmount);
      const burnAmount = ethers.parseEther("50");
      await token.burn(addr1.address, burnAmount);
      expect(await token.balanceOf(addr1.address)).to.equal(mintAmount - burnAmount);
    });
  });
});
