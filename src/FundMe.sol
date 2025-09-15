// FundMe.sol
// Allow users to send funds into the contract
// Enable withdrawal of funds by the contract owner
// Set a minimum funding value in USD

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "../src/AggregatorV3Interface.sol";

// creating custom errror to save the gas
error FundMe__NotOwner();
error FundMe__NotEnoughEth();
error FundMe__CallFailed();

contract FundMe {
    // we declare i_owner as immutable - because , we will get to know the value of i_owner at the time of deployment (means at runtime)
    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;
    //we are going to pass address everytime before deploying a contract ...for where we are going to deploy ()

    constructor(address priceFeed) {
        // Set the deployer as the owner
        i_owner = msg.sender;

        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // what happens if someone sends ETH to this contract wirthout calling the fund function
    // to handle plain ETH transfer
    receive() external payable {
        fund(); /*redirecting to the fund function*/
    }

    // to handle ETH teransfer with data
    fallback() external payable {
        fund();
    }

    // attaching library to the desired type: uint 256
    using PriceConverter for uint256;

    // we declare MINIMUM_USD as constant  - because , we will get to know the value of MINIMUM_USD at compile time.
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    // to keep track of: funders address
    address[] private s_funders;
    // to keep track of: how much fund is funded by the funder
    mapping(address funderAddress => uint256 amountFunded) private s_addressToAmountFunded;
    // to keep track of: how many times each funder funded to the contract
    mapping(address funderAddress => uint256 fundCount) private s_addressToFundCount;

    // to send funds into our contract by funders
    function fund() public payable {
        // require (msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH") ;
        // using custom error instead of require statement
        // due to the library, we can use getConversionRate function like below:
        if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) revert FundMe__NotEnoughEth();

        // adding funders to the array
        s_funders.push(msg.sender);
        // increasing fund amount of each funder
        s_addressToAmountFunded[msg.sender] += msg.value;
        // increasing fund count of each funder
        s_addressToFundCount[msg.sender] += 1;
    }

    // to count the fund count of every user: how much time each user sends the fund to contract
    function contributionCount(address userAddress) public view returns (uint256) {
        return s_addressToFundCount[userAddress];
    }

    // to get the number of users that sent funds into our contract
    function getFunderCount() public view returns (uint256) {
        return s_funders.length;
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner,"only the deployer can call this function");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // to withdraw funds from the contract
    // "onlyOwner" is a modifier
    function withdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        // require(msg.sender == owner, "you are not the owner");
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reseting the array-
        s_funders = new address[](0);
        // the one who is trying to withdraw a funds (such as contract owner)
        // contract will send the funds to owner
        // 3 methods to send a fund
        // 1. transfer
        // payable(msg.sender).transfer(address(this).balance);
        // the data type of:  msg.sender ==> address
        // the data type of:  payable(msg.sender) ==> payable address
        // 2. send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess , "send failed");
        // 3.call
        uint256 amount = address(this).balance;
        (bool callSuccess,) = payable(msg.sender).call{value: amount}("");
        // require(callSuccess, "call failed");
        // using if instead of require to save the gas
        if (!callSuccess) revert FundMe__CallFailed();
    }

    //just to get the correct version of chainlink price feed contract - for safety
    function getVersion() public view returns (uint256) {
        // return PriceConverter.getVersion();
        return s_priceFeed.version();
    }

    // creating getter funtions
    function getFundAmountFromAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunderAddress(uint256 i) external view returns (address) {
        return s_funders[i];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() external view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
