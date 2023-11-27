// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/ISBTContract.sol";
import "./interfaces/ISBTPriceContract.sol";
import "./interfaces/IERC20.sol";
import "./access/Ownable.sol";
import "./utils/math/Math.sol";

contract SaleContract is Ownable {
    using Math for uint256;

    ISBTContract public tokenContract;
    ISBTPriceContract public priceContract;
    IERC20 public stableContract = IERC20(0x28661511CDA7119B2185c647F23106a637CC074f);
    bool public killSwitch = false;
    uint256 public USDCDecimals = 10 ** 6;

    constructor() Ownable(_msgSender()) {
    }

     modifier checkSwitch() {
        require(killSwitch == false, "Contract stopped");
        _;
    }

    function setSwitch(bool _input) external onlyOwner() {
        killSwitch = _input;
    }

    function setSBTContract(address _contract) external onlyOwner() {
        tokenContract = ISBTContract(_contract);
    }

    function withdraw(uint256 _amount) external onlyOwner() {
        require(address(this).balance >= _amount, "Insufficient contract balance for withdrawal");
        payable(owner()).transfer(_amount);   
    }

    function withdrawUSDC(uint256 _amount) external onlyOwner() {
        stableContract.transfer(owner(), _amount);
    }

    function setPriceContract(address _contract) external onlyOwner() {
        priceContract = ISBTPriceContract(_contract);
    }

    function BuySBTUSDC() external checkSwitch() {
        uint256 price = priceContract.getPrice();
        stableContract.transferFrom(_msgSender(), address(this), price);
        tokenContract.mintSBT(_msgSender());
    }

    function BuySBTBFC() external payable checkSwitch() { // BFC : native token
        uint256 price = _SBTPriceBFC();
        require(msg.value == price, "Invalid Price");
        tokenContract.mintSBT(_msgSender());
    }

    function _SBTPriceBFC() internal view returns(uint256) {
        uint256 Ratio = priceContract.getBFCUSDCRatio();
        uint256 price = priceContract.getPrice();
        return price.mulDiv(Ratio, USDCDecimals);
    }

}