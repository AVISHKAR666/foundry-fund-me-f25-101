// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;

import {AggregatorV3Interface} from "../src/AggregatorV3Interface.sol";

// in library all function visibility should be internal
library PriceConverter {
    // to get the latest price of ETH in terms of USD
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // address:   0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        (, int256 price,,,) = priceFeed.latestRoundData();
        // price: it contains the price of 1 ETH in terms of USD
        // For eg. 1 ETH = 253789000000
        // it will look like this because solidity doesn't work with decimals
        // but we already know that it has 8 decimals like this: 2537.89000000
        // Because Chainlink’s ETH/USD feed returns the price with 8 decimals.
        // we also know that msg.value has 18 decimals
        // So, to match units, so we are adding extra 10 decimals

        return uint256(price * 1e10);
        // price * 1e10 = 253789000000 * 10¹⁰ = 253789000000000000000000
        // That’s the price of 1 ETH in USD with 18 decimal places.
    }

    // now we have to convert msg.value in terms of USD
    // msg.value : it is a fund that send by a user to the contract (it is in wei format means 1e18)
    // we have to find that how much ETH is send by user
    // for this we need msg.value(eth send by user) and latest price of ETH
    function getConversionRate(uint256 ethSendByUser, AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        uint256 latestEthPrice = getPrice(priceFeed);
        uint256 totalEthInUsd = (latestEthPrice * ethSendByUser) / 1e18;
        return totalEthInUsd;

        // always in solidity : multiply first then divide for precision
    }

    // just to get the correct version of chainlink price feed contract - for safety
    function getVersion(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        return priceFeed.version();
    }
}
