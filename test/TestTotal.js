const { expect } = require("chai");
const { ethers } = require("hardhat");
const helpers = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { constants } = require("@openzeppelin/test-helpers");
require("dotenv").config();

describe("After Contract Connect", function () {
  before(async function () {
    [owner, testUser] = await ethers.getSigners();
    const address = process.env.EVMAddress;
    await helpers.impersonateAccount(address);
    assetWallet = await ethers.getSigner(address);

    usdcContract = await ethers.getContractAt("IERC20", "0x28661511CDA7119B2185c647F23106a637CC074f");
    tokenContract = await ethers.deployContract("SBTContract", ["TokenforSale", "TfS"]);
    priceContract = await ethers.deployContract("SBTPriceContract");
    saleContract = await ethers.deployContract("SaleContract");

    await saleContract.setSBTContract(tokenContract.target);
    await saleContract.setSBTPriceContract(priceContract.target);
    await tokenContract.setSeller(saleContract.target);

    await usdcContract.connect(assetWallet).transfer(owner.address, 100000000);
    await usdcContract.connect(assetWallet).transfer(testUser.address, 100000000);
  });

  beforeEach(async function () {
    snapshotId = await network.provider.send("evm_snapshot");
  });

  afterEach(async function () {
    await network.provider.send("evm_revert", [snapshotId]);
  });

  describe("Initialize", function () {
    it("should correct initial state", async function () {
      expect(await tokenContract.name()).to.equal("TokenforSale");
      expect(await tokenContract.symbol()).to.equal("TfS");
      expect(await tokenContract.balanceOf(owner.address)).to.equal(0);
      expect(await tokenContract.owner()).to.equal(owner.address);
      expect(await tokenContract.count()).to.equal(0);
      expect(await tokenContract.seller()).to.equal(saleContract.target);

      expect(await priceContract.owner()).to.equal(owner.address);

      expect(await saleContract.killSwitch()).to.equal(false);
      expect(await saleContract.owner()).to.equal(owner.address);
      expect(await saleContract.tokenContract()).to.equal(tokenContract.target);
      expect(await saleContract.priceContract()).to.equal(priceContract.target);
      expect(await saleContract.stableContract()).to.equal("0x28661511CDA7119B2185c647F23106a637CC074f");

      expect(await usdcContract.balanceOf(owner.address)).to.equal(100000000);
      expect(await usdcContract.balanceOf(testUser.address)).to.equal(100000000);
    });
  });

  describe("Oracle Data Test", function () {
    it("should price is zero", async function () {
      expect(await priceContract.getSBTPriceBFC()).to.equal(0);
    });

    it("should fail verify data", async function () {
      await helpers.time.increase(2000);
      await expect(priceContract.getSBTPriceBFC()).to.be.revertedWith("Failed data integrity check");
    });
  });

  describe("User test", function () {
    before(async function () {
      await priceContract.setSBTPrice(2000000);
      bfcPrice = await priceContract.getSBTPriceBFC();
      usdcPrice = await priceContract.getSBTPriceUSDC();
    });

    it("should get price", async function () {
      expect(await priceContract.getSBTPriceUSDC()).to.be.equal("2000000");
    });

    it("should fail mint before token approve", async function () {
      await expect(saleContract.buySBTUSDC()
      ).to.be.revertedWith("ERC20: insufficient allowance");
      await expect(saleContract.connect(testUser).buySBTUSDC()
      ).to.be.revertedWith("ERC20: insufficient allowance");
    });

    it("should mint exact value(USDC)", async function () {
      await usdcContract.approve(saleContract.target, usdcPrice);
      await expect(await saleContract.buySBTUSDC());
      expect(await tokenContract.balanceOf(owner.address)).to.equal(1);
      expect(await tokenContract.ownerOf(1)).to.equal(owner.address);

      await usdcContract.connect(testUser).approve(saleContract.target, usdcPrice);
      await expect(await saleContract.connect(testUser).buySBTUSDC());
      expect(await tokenContract.connect(testUser).balanceOf(testUser.address)).to.equal(1);
      expect(await tokenContract.connect(testUser).ownerOf(2)).to.equal(testUser.address);
    });

    it("should fail inexact value(BFC)", async function () {
      const errorPrice = (await priceContract.getSBTPriceBFC()) + `3`;
      await expect(saleContract.buySBTBFC({ value: errorPrice })
      ).to.be.revertedWith("Invalid price");
      await expect(saleContract.connect(testUser).buySBTBFC({ value: errorPrice })
      ).to.be.revertedWith("Invalid price");
    });

    it("should mint exact value(BFC)", async function () {
      const bfcPrice = await priceContract.getSBTPriceBFC();

      await expect(await saleContract.buySBTBFC({ value: bfcPrice }));
      expect(await tokenContract.balanceOf(owner.address)).to.equal(1);
      expect(await tokenContract.ownerOf(1)).to.equal(owner.address);

      await expect(await saleContract.connect(testUser).buySBTBFC({ value: bfcPrice }));
      expect(await tokenContract.connect(testUser).balanceOf(testUser.address)).to.equal(1);
      expect(await tokenContract.connect(testUser).ownerOf(2)).to.equal(testUser.address);
    });

    it("should emit 'Issued, Transfer' event", async () => {
      await expect(await saleContract.buySBTBFC({ value: bfcPrice }))
        .to.emit(tokenContract, "Issued").withArgs(saleContract.target, owner.address, 1, 1)
        .to.emit(tokenContract, "Transfer").withArgs(constants.ZERO_ADDRESS, owner.address, 1);

      await usdcContract.connect(testUser).approve(saleContract.target, usdcPrice);
      await expect(await saleContract.connect(testUser).buySBTUSDC())
        .to.emit(tokenContract, "Issued").withArgs(saleContract.target, testUser.address, 2, 1)
        .to.emit(tokenContract, "Transfer").withArgs(constants.ZERO_ADDRESS, testUser.address, 2);
    });

    it("should change BFC balance", async () => {
      await expect(await saleContract.buySBTBFC({ value: bfcPrice })
      ).to.changeEtherBalances([owner, saleContract], ["-" + bfcPrice, bfcPrice]);
    });

    it("should change USDC balance", async () => {
      await usdcContract.approve(saleContract.target, usdcPrice);
      await expect(await saleContract.buySBTUSDC()
      ).to.changeTokenBalances(usdcContract, [owner, saleContract], ["-" + usdcPrice, usdcPrice]);
    });
  });

  describe("Kill switch on", function () {
    before(async function () {
      await priceContract.setSBTPrice(2000000);
      bfcPrice = await priceContract.getSBTPriceBFC();
      usdcPrice = await priceContract.getSBTPriceUSDC();
      await saleContract.setSwitch(true);
    });

    it("should fail mint", async function () {
      await usdcContract.approve(saleContract.target, usdcPrice);
      await expect(saleContract.buySBTUSDC()
      ).to.be.revertedWith("Contract stopped");

      await usdcContract.connect(testUser).approve(saleContract.target, usdcPrice);
      await expect(saleContract.connect(testUser).buySBTUSDC()
      ).to.be.revertedWith("Contract stopped");

      const errorPrice = (await priceContract.getSBTPriceBFC()) + `3`;
      await expect(saleContract.buySBTBFC({ value: errorPrice })
      ).to.be.revertedWith("Contract stopped");
      await expect(saleContract.connect(testUser).buySBTBFC({ value: errorPrice })
      ).to.be.revertedWith("Contract stopped");

      await expect(saleContract.buySBTBFC({ value: bfcPrice })
      ).to.be.revertedWith("Contract stopped");
      await expect(saleContract.connect(testUser).buySBTBFC({ value: bfcPrice })
      ).to.be.revertedWith("Contract stopped");
    });

  });


  // 출금 , 킬스위치
});