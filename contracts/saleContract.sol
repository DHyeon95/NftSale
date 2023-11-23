// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ISBTContract.sol";
import './access/Ownable.sol';

contract saleContract is Ownable {

    ISBTContract sbtContract ;
    bool private killswitch = false ;
    address USDCContract ;

    modifier checkSwitch() {
        require(killswitch == false, "Contract stopped");
        _ ;
    }

    function setSwitch(bool _input) external onlyOwner() {
        killswitch = _input ;
    }

    function setContract(address _contract) external onlyOwner() {
        sbtContract = ISBTContract( _contract ) ;
    }

    function BuySBTUSDC() public {
        uint256 price = MockingFunction_GetSBTPriceUSDC();
        USDCContract.trasferFrom(msg.sender, address(this) , price);
        sbtContract.testMint(msg.sender);
    }

    function BuySBTBFC() public payable { // BFC : native token
        uint256 price = MockingFunction_GetBFCPriceUSDC();
        require(msg.value == price, "Invalid Price");
        sbtContract.testMint(msg.sender);
    }

}