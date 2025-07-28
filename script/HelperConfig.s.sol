// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    // refactor magic numbers
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public currentNetworkConfig;

    struct NetworkConfig{
        address priceFeedAddress;
    }

    constructor(){
        if(block.chainid==11155111){
            currentNetworkConfig = getSepoliaEthConfig();
        }
        else if(block.chainid==4){
            currentNetworkConfig = getMainnetEthConfig();
        }
        else{
            currentNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    // 1. grab the existing address from the live network

    function getSepoliaEthConfig() pure public returns(NetworkConfig memory){
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeedAddress:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() pure public returns(NetworkConfig memory){
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeedAddress:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }



    // 2. if we are on a local anvil, we deploy mock pricefeed contract
    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){

        if (currentNetworkConfig.priceFeedAddress != address(0)) {
            return currentNetworkConfig;
        }

        // here we are deploying a mock pricefeed contract , to get mock pricefeed address
        // 1. deploy the mock
        // 2. return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeedContract = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeedAddress : address(mockPriceFeedContract) 
        });
        return anvilConfig;
    }

}