// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/ISBTContract.sol";
import "./interfaces/ISBTPriceContract.sol";
import "./interfaces/IERC20.sol";
import "./access/Ownable.sol";

contract SaleContract is Ownable {
  ISBTContract public tokenContract;
  ISBTPriceContract public priceContract;
  IERC20 public stableContract = IERC20(0x28661511CDA7119B2185c647F23106a637CC074f);
  bool public killSwitch = false;

  modifier checkSwitch() {
    require(killSwitch == false, "Contract stopped");
    _;
  }

  modifier checkContract() {
    require(tokenContract != ISBTContract(address(0)), "Contract not setting");
    require(priceContract != ISBTPriceContract(address(0)), "Contract not setting");
    _;
  }

  constructor() Ownable(_msgSender()) {}

  function buySBTBFC() external payable checkContract checkSwitch {
    // BFC : native token
    uint256 price = priceContract.getSBTPriceBFC();
    require(msg.value == price, "Invalid price");
    tokenContract.mintSBT(_msgSender());
  }

  function buySBTUSDC() external checkContract checkSwitch {
    uint256 price = priceContract.getSBTPriceUSDC();
    stableContract.transferFrom(_msgSender(), address(this), price);
    tokenContract.mintSBT(_msgSender());
  }

  function withdrawBFC(uint256 _amount) external checkSwitch onlyOwner {
    require(address(this).balance >= _amount, "Insufficient contract balance for withdrawal");
    payable(owner()).transfer(_amount);
  }

  function withdrawUSDC(uint256 _amount) external checkSwitch onlyOwner {
    stableContract.transfer(owner(), _amount);
  }

  function setSBTPriceContract(address _contract) external onlyOwner {
    priceContract = ISBTPriceContract(_contract);
  }

  function setSwitch(bool _input) external onlyOwner {
    killSwitch = _input;
  }

  function setSBTContract(address _contract) external onlyOwner {
    tokenContract = ISBTContract(_contract);
  }
}
