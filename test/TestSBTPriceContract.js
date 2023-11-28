const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SBTPriceContract", function () {
  before(async function () {
    [owner, testUser] = await ethers.getSigners();
    priceContract = await ethers.deployContract("SBTPriceContract");
  });

  describe("Initialize", function () {
    it("should correct initial state", async function () {
      expect(await priceContract.owner()).to.equal(owner.address);
    });
  });

  describe("Set state", function () {
    it("should fail set Price from other", async function () {
      await expect(priceContract.connect(testUser).setSBTPrice(100)
      ).to.be.revertedWithCustomError(priceContract, "OwnableUnauthorizedAccount");
    });

    it("should set Price from owner", async function () {
      await priceContract.setSBTPrice(100);
      expect(await priceContract.SBTPrice()).to.equal(100);
    });
  });
});
