// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC5484/ERC5484.sol";
import "./access/Ownable.sol";
import "./interfaces/ISBTContract.sol";
import "./utils/math/Math.sol";

contract SBTContract is ERC5484, Ownable, ISBTContract {
  using Math for uint256;

  uint256 public count;
  address public seller;

  constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(_msgSender()) {}

  function setSeller(address _seller) external onlyOwner {
    seller = _seller;
  }

  function mintSBT(address to) external {
    require(_msgSender() == seller, "Invalid seller");
    (bool chkCalculation, uint256 _count) = count.tryAdd(1);
    require(chkCalculation == true, "Calculation fail");
    count = _count;
    _mintSBT(to, count, BurnAuth.OwnerOnly);
  }
}
