// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC5484/ERC5484.sol";
import "./access/Ownable.sol";
import "./interfaces/ISBTContract.sol";

contract SBTContract is ERC5484, Ownable, ISBTContract {
  uint256 public count = 0;
  address public seller;

  constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(_msgSender()) {}

  function setSeller(address _seller) external onlyOwner {
    seller = _seller;
  }

  function mintSBT(address to) external {
    require(_msgSender() == seller, "Invalid seller");
    count = count + 1;
    _mintSBT(to, count, BurnAuth.OwnerOnly);
  }
}
