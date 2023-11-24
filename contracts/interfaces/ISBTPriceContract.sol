pragma solidity ^0.8.20;

interface ISBTPriceContract {
    function getBFCUSDCRatio() external view returns (uint, uint);
    function getPrice() external view returns(uint);
}