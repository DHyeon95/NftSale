// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/ISBTContract.sol";
import "./interfaces/ISBTPriceContract.sol";
import "./interfaces/IERC20.sol";
import "./access/Ownable.sol";
import "./utils/math/Math.sol";


contract saleContract is Ownable {
    using Math for uint256;

    ISBTContract private tokenContract;
    ISBTPriceContract private priceContract;
    IERC20 private stableContract = IERC20(0x28661511CDA7119B2185c647F23106a637CC074f);
    bool private killswitch = false;

    constructor() Ownable(_msgSender()) {
    }

     modifier checkSwitch() {
        require(killswitch == false, "Contract stopped");
        _;
    }

    function setSwitch(bool _input) external onlyOwner() {
        killswitch = _input;
    }

    function setSBTContract(address _contract) external onlyOwner() {
        tokenContract = ISBTContract(_contract);
    }

    function withdraw(uint256 _amount) external onlyOwner() {
        require(address(this).balance >= _amount, "Insufficient contract balance for withdrawal");
        payable(owner()).transfer(_amount);   
    }

    function withdrawUSDC(uint256 _amount) external onlyOwner() {
        stableContract.transfer(owner(), _amount); // decimals 처리해야함
    }

    function setPriceContract(address _contract) external onlyOwner() {
        priceContract = ISBTPriceContract(_contract);
    }

    function BuySBTUSDC() external checkSwitch() {
        uint256 price = priceContract.getPrice(); // decimals 처리해야함
        stableContract.transferFrom(msg.sender, address(this) , price);
        tokenContract.testMint(msg.sender);
    }

    function BuySBTBFC() external payable checkSwitch() { // BFC : native token
        uint256 price = _SBTPriceBFC();
        require(msg.value == price, "Invalid Price");
        tokenContract.testMint(msg.sender);
    }

    // 가격 연산 함수 view
    function _SBTPriceBFC() internal view returns(uint256) {
        (uint256 amount, uint256 Ratio) = priceContract.getBFCUSDCRatio();
        uint256 price = priceContract.getPrice();
        // 멀티콜? 혹은 priceContract의 한 함수에 다 넣기
        uint256 returnPrice = price * amount.mulDiv(10 ** 18, 10 ** Ratio);
        return returnPrice;
    }

}