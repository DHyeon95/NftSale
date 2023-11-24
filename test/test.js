const { expect } = require('chai')
const { ethers } = require('hardhat')
const { constants } = require('@openzeppelin/test-helpers')
const helpers = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe('test5484',  function () {

    it('should correct name', async function () {
        const MyContract = await ethers.getContractAt("IERC20", "0x0x28661511CDA7119B2185c647F23106a637CC074f");
        const address = "0xbf22b27ceC1F1c8fc04219ccCCb7ED6F6F4f8030";
        await helpers.impersonateAccount(address);
        const impersonatedSigner = await ethers.getSigner(address);
        const owner = await ethers.getSigner();
        console.log( 'test add : ' , impersonatedSigner.address ) ;
        // console.log(await MyContract);
    })
    

})

// const MyContract = await ethers.getContractFactory("MyContract");
// const contract = MyContract.attach(
//   "0x..." // The deployed contract address
// );



// PRICE 0x1FBD876669E857943593DE074dae507f1Af77ec8
// SALE 0xdeeBE7a7d0c98AC7dA2050dF11b756F73Bfc33Ff
// SBT 0xDD30c96dAC77e444dF36F69A965e50C3460A8De4
// ERC20 0x28661511CDA7119B2185c647F23106a637CC074f

// 0xbf22b27ceC1F1c8fc04219ccCCb7ED6F6F4f8030
