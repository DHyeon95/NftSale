const { expect } = require("chai");
const { ethers } = require("hardhat");
const { constants } = require("@openzeppelin/test-helpers");

describe("SaleContract", function () {
  before(async function () {
    [owner, testUser] = await ethers.getSigners();
    saleContract = await ethers.deployContract("SaleContract");
  });

  beforeEach(async function () {
    snapshotId = await network.provider.send("evm_snapshot");
  });

  afterEach(async function () {
    await network.provider.send("evm_revert", [snapshotId]);
  });

  describe("Initialize", function () {
    it("should correct initial state", async function () {
      expect(await saleContract.killSwitch()).to.equal(false);
      expect(await saleContract.owner()).to.equal(owner.address);
      expect(await saleContract.tokenContract()).to.equal(constants.ZERO_ADDRESS);
      expect(await saleContract.priceContract()).to.equal(constants.ZERO_ADDRESS);
      expect(await saleContract.stableContract()).to.equal("0x28661511CDA7119B2185c647F23106a637CC074f");
    });
  });

  describe("Set state", function () {
    it("should set state from owner", async function () {
      await saleContract.setSwitch(true);
      expect(await saleContract.killSwitch()).to.equal(true);

      await saleContract.setSBTContract(testUser.address);
      expect(await saleContract.tokenContract()).to.equal(testUser.address);

      await saleContract.setSBTPriceContract(testUser.address);
      expect(await saleContract.priceContract()).to.equal(testUser.address);
    });

    it("should fail set state from other", async function () {
      await expect(saleContract.connect(testUser).setSwitch(true)).to.be.revertedWithCustomError(
        saleContract,
        "OwnableUnauthorizedAccount",
      );
      expect(await saleContract.killSwitch()).to.equal(false);

      await expect(saleContract.connect(testUser).setSBTContract(testUser.address)).to.be.revertedWithCustomError(
        saleContract,
        "OwnableUnauthorizedAccount",
      );
      expect(await saleContract.tokenContract()).to.equal(constants.ZERO_ADDRESS);

      await expect(saleContract.connect(testUser).setSBTPriceContract(testUser.address)).to.be.revertedWithCustomError(
        saleContract,
        "OwnableUnauthorizedAccount",
      );
      expect(await saleContract.priceContract()).to.equal(constants.ZERO_ADDRESS);
    });
  });

  describe("Withdraw asset", function () {
    it("should fail withdraw", async function () {
      await expect(saleContract.withdrawUSDC(100)).to.be.revertedWith("ERC20: transfer amount exceeds balance");
      await expect(saleContract.withdrawBFC(100)).to.be.revertedWith("Insufficient contract balance for withdrawal");
    });
  });

  describe("Mismatch contract", function () {
    it("shoule fail buySBT", async function () {
      await expect(saleContract.buySBTUSDC()).to.be.revertedWith("Contract not setting");
      await expect(saleContract.buySBTBFC()).to.be.revertedWith("Contract not setting");
    });

    it("shoule fail buySBT", async function () {
      await saleContract.setSBTContract("0xbf22b27ceC1F1c8fc04219ccCCb7ED6F6F4f8030");
      await saleContract.setSBTPriceContract("0xbf22b27ceC1F1c8fc04219ccCCb7ED6F6F4f8030");
      await expect(saleContract.buySBTUSDC()).to.be.reverted;
      await expect(saleContract.buySBTBFC()).to.be.reverted;
    });
  });
});
