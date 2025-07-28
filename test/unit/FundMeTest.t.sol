// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import "../../src/FundMe.sol";
import "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 10e18;
    uint256 constant STARTING_BALANCE = 100e18;



    function setUp() public {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }


    function testMinimumUsd() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
        // instaed of  "msg.sender" we used "address(this)" becz 
        // here "FundMeTest" contract is deploying our "FundMe" contract hence
        // again cjanging it to the msg.sender
    }

    function testPriceFeedVersionIsAccurate() public view{
        if(block.chainid==11155111){
            AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
            uint256 version = PriceConverter.getVersion(priceFeed);
            assertEq(version, 4);
        }
        else if(block.chainid==1){
            AggregatorV3Interface priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
            uint256 version = PriceConverter.getVersion(priceFeed);
            assertEq(version, 6);
        } 
    }

    function testFundFailsWithoutSendingEnoughEth() public {
        // in "expectRevert()", when tx fails, the test will be passed
        // and if the tx doesn't fails, the test will be failed
        vm.expectRevert();
        // uint8 cat = 1; //this tx will pass but test will fail
        fundMe.fund();
        // here we are calling "fund" function without any value 
        // so eventually this tx is going to fail and test is going to passed 
    }

    modifier funded (){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded{
        uint256 amountFunded = fundMe.getFundAmountFromAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFundersToArrayOfFunders() public funded{
        address funder = fundMe.getFunderAddress(0);
        assertEq(funder, USER);
    }

    function testONlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded{
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        

        // Asert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq (endingFundMeBalance, 0);
        assertEq (startingOwnerBalance + startingFundMeBalance , endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() public funded {
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex ; i<numberOfFunders; i++) {
            // here we have to create multiple user address with some ether
            // we can create them with vm.prank and deal
            // but by using  "hoax" we can do both in one

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act 
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, fundMe.getOwner().balance);
    }
}



