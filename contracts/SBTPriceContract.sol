// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IOracle.sol";
import "./interfaces/ISBTPriceContract.sol";
import "./access/Ownable.sol";
import "./utils/math/Math.sol";

contract SBTPriceContract is ISBTPriceContract, Ownable {
  using Math for uint256;

  uint256 public tokenPrice;
  IOracle internal dataFeed;
  uint256 constant decimalsUSDC = 10 ** 6;

  /**
   * Network: BFC_Testnet
   * Aggregator: BFC/USDC
   * Address: 0x18Ff9c6B6777B46Ca385fd17b3036cEb30982ea9
   */
  constructor(uint256 _price) Ownable(_msgSender()) {
    dataFeed = IOracle(0x18Ff9c6B6777B46Ca385fd17b3036cEb30982ea9);
    tokenPrice = _price;
  }

  function setSBTPrice(uint256 _input) external onlyOwner {
    tokenPrice = _input;
  }

  // saleContract 에서 호출하기 위함
  function getSBTPriceUSDC() external view returns (uint256) {
    return tokenPrice;
  }

  function getSBTPriceBFC() external view returns (uint256) {
    uint256 ratio = _getBFCUSDCRatio();
    uint256 price = tokenPrice;
    price = price.mulDiv(ratio, decimalsUSDC);
    price /= 10 ** 15;
    price *= 10 ** 15;
    return price;
  }

  function _getBFCUSDCRatio() internal view returns (uint256) {
    int256 oralcePrice = _getChainlinkDataFeedLatestAnswer();
    require(oralcePrice > 0, "Failed data integrity check");
    uint256 divPrice = uint256(oralcePrice);
    uint256 ratio = 10 ** 26;
    return ratio / divPrice;
  }

  function _getChainlinkDataFeedLatestAnswer() internal view returns (int256) {
    (, int256 answer, , uint256 timeStamp, ) = dataFeed.latestRoundData();
    require(block.timestamp < timeStamp + 2000, "Failed data integrity check");
    return (answer);
  }
}
