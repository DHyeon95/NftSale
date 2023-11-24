// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/IOracle.sol";
import "./interfaces/ISBTPriceContract.sol";

contract SBTPriceContract is ISBTPriceContract{

    uint private SBTPrice;

    function getPrice() external view returns(uint){
        return SBTPrice ;
    }

    function setPrice(uint _input) external{
        SBTPrice = _input;
    }

    IOracle internal dataFeed;
    /**
     * Network: BFC_Testnet
     * Aggregator: BFC/USDC
     * Address: 0x18Ff9c6B6777B46Ca385fd17b3036cEb30982ea9
     */
    constructor() {
        dataFeed = IOracle(
            0x18Ff9c6B6777B46Ca385fd17b3036cEb30982ea9
        );
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return (answer);
    }

    // Ratio / (10 ** divcount) = Amount
    // 1 USDC = Amount BFC
    function getBFCUSDCRatio() public view returns (uint, uint){
        int oralcePrice = getChainlinkDataFeedLatestAnswer();
        require( oralcePrice > 0 , "Oracle Data Minus");

        /*
        uint Ratio = uint(oralcePrice);
        uint div = 10 ** 26 ;
        return div / Ratio;
        Ratio / (10 ** divcount) = Amount
        1 USDC = Amount BFC
        */

        uint Ratio = uint(oralcePrice);
        uint div = 10 ** 8;
        uint divcount = 3;

        while( div < Ratio ){
            div *= 10;
            divcount +=1;
        }
        div *= 1000;

        Ratio = div / Ratio;
        return (Ratio, divcount);
    }
}

/*
0: int256: 5036900
1: uint256: 1700721648
getBFCUSDCRatio( 1 ) : 1985
*/

// difer : 1854

/*
0: int256: 4960828
1: uint256: 1700723502
getBFCUSDCRatio( 1 ) : 2015
*/

// difer : 1851

/*
0: int256: 4986515
1: uint256: 1700725353
getBFCUSDCRatio( 1 ) : 2015
*/
