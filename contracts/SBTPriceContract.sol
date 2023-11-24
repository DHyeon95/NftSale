// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/IOracle.sol";
import "./interfaces/ISBTPriceContract.sol";
import "./utils/math/Math.sol";
import "./access/Ownable.sol";

contract SBTPriceContract is ISBTPriceContract, Ownable{
    using Math for uint256;

    uint public SBTPrice;
    IOracle internal dataFeed;

    /**
     * Network: BFC_Testnet
     * Aggregator: BFC/USDC
     * Address: 0x18Ff9c6B6777B46Ca385fd17b3036cEb30982ea9
     */
    constructor() Ownable(_msgSender()) {
        dataFeed = IOracle(0x18Ff9c6B6777B46Ca385fd17b3036cEb30982ea9);
    }

    function setPrice(uint _input) external onlyOwner() {
        SBTPrice = _input;
    }

    function getPrice() external view returns(uint) { // saleContract
        return SBTPrice;
    }

    function getBFCUSDCRatio() external view returns (uint){
        int oralcePrice = getChainlinkDataFeedLatestAnswer();
        require(oralcePrice > 0, "Oracle Data Minus");
        uint divPrice = uint(oralcePrice);
        uint ratio = 10 ** 26;
        return ratio / divPrice;
    }

    function getChainlinkDataFeedLatestAnswer() internal view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return (answer);
    }

}