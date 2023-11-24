// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISBTPriceContract {
    function getPrice() external view returns(uint);
    function getBFCUSDCRatio() external view returns (uint);
}