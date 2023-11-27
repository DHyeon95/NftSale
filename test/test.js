const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const { constants } = require("@openzeppelin/test-helpers");
const helpers = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Before Contract Connect", function () {

  describe("SBTContract", function () {

    before(async function () {
      [owner, testUser] = await ethers.getSigners();
      SBTContract = await ethers.deployContract("SBTContract", ["TokenforSale", "TfS"]);
    });

    beforeEach(async function () {
      snapshotId = await network.provider.send("evm_snapshot");
    });

    afterEach(async function () {
      await network.provider.send("evm_revert", [snapshotId]);
    });

    describe("Initialize", function () {
      it("should correct initial state", async function () {
        expect(await SBTContract.name()).to.equal("TokenforSale");
        expect(await SBTContract.symbol()).to.equal("TfS");
        expect(await SBTContract.balanceOf(owner.address)).to.equal(0);
        expect(await SBTContract.owner()).to.equal(owner.address);
        expect(await SBTContract.count()).to.equal(0);
        expect(await SBTContract.seller()).to.equal(constants.ZERO_ADDRESS);
      });
    });

    describe("Set state", function () {
      it("should fail set Seller from other", async function () {
        await expect(
          SBTContract.connect(testUser).setSeller(testUser.address)
        ).to.be.revertedWithCustomError(SBTContract, "OwnableUnauthorizedAccount");
      });
      
      it("should set Seller from owner", async function () {
        await SBTContract.setSeller(owner.address);
        expect(await SBTContract.seller()).to.equal(owner.address);
      });
    });

    describe("mintSBT", function () {
      describe("Before set seller", function () {
        it("should fail mint", async function () {
          await expect(
            SBTContract.connect(testUser).mintSBT(owner.address)
          ).to.be.revertedWith("Invalid seller");
          await expect(SBTContract.mintSBT(owner.address)).to.be.revertedWith(
            "Invalid seller"
          );
        });
      });

      describe("After set seller", function () {
        before( async function() {
            await SBTContract.setSeller(testUser.address);
        })

        // issued, transfer 이벤트 체크
        it("should mint from seller", async function () {
          await expect(SBTContract.connect(testUser).mintSBT(testUser.address))
            .to.emit(SBTContract, "Issued")
            .withArgs(testUser.address, testUser.address, 1, 1)
            .to.emit(SBTContract, "Transfer")
            .withArgs(constants.ZERO_ADDRESS, testUser.address, 1);
          expect(await SBTContract.balanceOf(testUser.address)).to.equal(1);
          expect(await SBTContract.ownerOf(1)).to.equal(testUser.address);
        });

        it("disallow mint from others", async function () {
          await expect(
            SBTContract.connect(owner).mintSBT(owner.address)
          ).to.be.revertedWith("Invalid seller");
        });
      });
    });

  });

  describe("PriceContract", function () {
    before(async function () {
      [owner, testUser] = await ethers.getSigners();
      SBTPriceContract = await ethers.deployContract("SBTPriceContract");
    });

    describe("Initialize", function () {
      it("should correct initial state", async function () {
        expect(await SBTPriceContract.owner()).to.equal(owner.address);
      });
    });

    describe("Set state", function () {
      it("should fail set Price from other", async function () {
          await expect(
              SBTPriceContract.connect(testUser).setPrice(100)
          ).to.be.revertedWithCustomError(SBTPriceContract, "OwnableUnauthorizedAccount");
      });
         
      it("should set Price from owner", async function () {
          await SBTPriceContract.setPrice(100);
          expect(await SBTPriceContract.SBTPrice()).to.equal(100);
      });
    })
  });

  describe("SaleContract", function () {
    before(async function () {
        [owner, testUser] = await ethers.getSigners();
        SaleContract = await ethers.deployContract("SaleContract");
      });
  
      beforeEach(async function () {
        snapshotId = await network.provider.send("evm_snapshot");
      });
  
      afterEach(async function () {
        await network.provider.send("evm_revert", [snapshotId]);
      });
  
      describe("Initialize", function () { 
        it("should correct initial state", async function () {
          expect(await SaleContract.killSwitch()).to.equal(false);
          expect(await SaleContract.owner()).to.equal(owner.address);
          expect(await SaleContract.tokenContract()).to.equal(constants.ZERO_ADDRESS);
          expect(await SaleContract.priceContract()).to.equal(constants.ZERO_ADDRESS);
          expect(await SaleContract.stableContract()).to.equal("0x28661511CDA7119B2185c647F23106a637CC074f");
        });
      });

      describe("Set state", function () {
        it("should set state from owner", async function () {
          await SaleContract.setSwitch(true);
          expect(await SaleContract.killSwitch()).to.equal(true);
          await SaleContract.setSBTContract(testUser.address)
          expect(await SaleContract.tokenContract()).to.equal(testUser.address);
          await SaleContract.setPriceContract(testUser.address)
          expect(await SaleContract.priceContract()).to.equal(testUser.address);
        })

        it("should fail set state from other", async function () {
          await expect(SaleContract.connect(testUser).setSwitch(true)).to.be.revertedWithCustomError(SBTPriceContract, "OwnableUnauthorizedAccount");
          expect(await SaleContract.killSwitch()).to.equal(false);
          await expect(SaleContract.connect(testUser).setSBTContract(testUser.address)).to.be.revertedWithCustomError(SBTPriceContract, "OwnableUnauthorizedAccount");
          expect(await SaleContract.tokenContract()).to.equal(constants.ZERO_ADDRESS);
          await expect(SaleContract.connect(testUser).setPriceContract(testUser.address)).to.be.revertedWithCustomError(SBTPriceContract, "OwnableUnauthorizedAccount");
          expect(await SaleContract.priceContract()).to.equal(constants.ZERO_ADDRESS);
        })
      })

      // describe("")

      // console.log( await ethers.provider.getBalance(owner.address));
      // await owner.sendTransaction({ to: testUser.address, value: 200 });


  })

});

// describe("test5484", function () {
//   it("should correct name", async function () {
//     const usdcContract = await ethers.getContractAt(
//       "IERC20",
//       "0x28661511CDA7119B2185c647F23106a637CC074f"
//     );
//     const address = testUser.address;

//     await helpers.impersonateAccount(address);
//     const impersonatedSigner = await ethers.getSigner(address);
//     const owner = await ethers.getSigners();
//   });
// });

// const MyContract = await ethers.getContractFactory("MyContract");
// const contract = MyContract.attach(
//   "0x..." // The deployed contract address
// );



// PRICE 0x1FBD876669E857943593DE074dae507f1Af77ec8
// SALE 0xdeeBE7a7d0c98AC7dA2050dF11b756F73Bfc33Ff
// SBT 0xDD30c96dAC77e444dF36F69A965e50C3460A8De4
// ERC20 0x28661511CDA7119B2185c647F23106a637CC074f

// 0xbf22b27ceC1F1c8fc04219ccCCb7ED6F6F4f8030
