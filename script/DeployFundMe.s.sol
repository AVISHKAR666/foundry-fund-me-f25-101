// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    // this function will run our "FundMe" contract
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeedAddress = helperConfig.currentNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeedAddress);
        vm.stopBroadcast();
        return fundMe;
    }
}
