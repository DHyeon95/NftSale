// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IOracle.sol";
import "./interfaces/ISBTPriceContract.sol";
import "./access/Ownable.sol";
import "./utils/math/Math.sol";

contract SBTPriceContract is ISBTPriceContract, Ownable {
  using Math for uint256;

  uint256 public tokenPrice;
  uint256 public timeInterval;
  uint256 internal constant decimalsUSDC = 10 ** 6;
  IOracle internal immutable dataFeed;

  /**
   * Network: BFC_Testnet
   * Aggregator: BFC/USDC
   * Address: 0x18Ff9c6B6777B46Ca385fd17b3036cEb30982ea9
   */
  constructor(uint256 price) Ownable(_msgSender()) {
    dataFeed = IOracle(0x18Ff9c6B6777B46Ca385fd17b3036cEb30982ea9);
    tokenPrice = price;
  }

  function setInterval(uint256 input) external onlyOwner {
    timeInterval = input;
  }

  function setSBTPrice(uint256 input) external onlyOwner {
    tokenPrice = input;
  }

  // saleContract 에서 호출하기 위함
  function getSBTPriceUSDC() external view returns (uint256) {
    return tokenPrice;
  }

  function getSBTPriceBFC() external view returns (uint256) {
    uint256 ratio = _getBFCUSDCRatio();
    uint256 price = tokenPrice;
    price = price.mulDiv(ratio, decimalsUSDC);
    (bool chkCalculation1, uint256 _price1) = price.tryDiv(10 ** 15);
    require(chkCalculation1 == true, "Calculation fail");
    price = _price1;
    (bool chkCalculation2, uint256 _price2) = price.tryMul(10 ** 15);
    require(chkCalculation2 == true, "Calculation fail");
    price = _price2;
    return price;
  }

  function _getBFCUSDCRatio() internal view returns (uint256) {
    int256 oralcePrice = _getChainlinkDataFeedLatestAnswer();
    require(oralcePrice > 0, "Failed data integrity check");
    uint256 ratio = 10 ** 26;
    (bool chkCalculation, uint256 price) = ratio.tryDiv(uint256(oralcePrice));
    require(chkCalculation == true, "Calculation fail");
    ratio = price;
    return ratio;
  }

  function _getChainlinkDataFeedLatestAnswer() internal view returns (int256) {
    (, int256 answer, , uint256 timeStamp, ) = dataFeed.latestRoundData();
    require(block.timestamp < timeStamp + timeInterval, "Failed data integrity check");
    return (answer);
  }
}
