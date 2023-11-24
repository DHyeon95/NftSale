
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC5484.sol";
import "./access/Ownable.sol";
import "./interfaces/ISBTContract.sol";

contract SBTContract is ERC5484, Ownable, ISBTContract {

    uint private totalsupply = 0;
    address private seller = address(0);

    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(_msgSender()) {}

    function getTotalSupply() external view returns(uint) {
        return totalsupply;
    }

    function getSeller() external view returns(address) {
        return seller;
    }

    function setSeller(address _seller) external onlyOwner() {
        seller = _seller;
    }

    function testMint(address to) external {
        require(_msgSender() == seller, "Invalid seller");
        totalsupply = totalsupply + 1;
        _mintSBT(to, totalsupply, BurnAuth.OwnerOnly);
    }

    function testBurn(uint256 tokenId) external {
        _burnSBT(tokenId);
    }

}