// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/IOracle.sol";
import "./interfaces/ISBTPriceContract.sol";
import "./access/Ownable.sol";

contract SBTPriceContract is ISBTPriceContract, Ownable{

    uint256 public SBTPrice;
    IOracle internal dataFeed;

    /**
     * Network: BFC_Testnet
     * Aggregator: BFC/USDC
     * Address: 0x18Ff9c6B6777B46Ca385fd17b3036cEb30982ea9
     */
    constructor() Ownable(_msgSender()) {
        dataFeed = IOracle(0x18Ff9c6B6777B46Ca385fd17b3036cEb30982ea9);
    }

    function setPrice(uint256 _input) external onlyOwner() {
        SBTPrice = _input;
    }

    function getPrice() external view returns(uint256) { // saleContract
        return SBTPrice;
    }

    function getBFCUSDCRatio() external view returns (uint256){
        int oralcePrice = getChainlinkDataFeedLatestAnswer();
        require(oralcePrice > 0, "Oracle Data Minus");
        uint256 divPrice = uint256(oralcePrice);
        uint256 ratio = 10 ** 26;
        return ratio / divPrice;
    }

    function getChainlinkDataFeedLatestAnswer() internal view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint256 startedAt*/,
            /*uint256 timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return (answer);
    }

}