// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import { DeployRaffle } from "../../script/DeployRaffle.s.sol";
import { Raffle } from "../../src/Raffle.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";
import { Test, Console } from "forge-std/Script.sol";
import { Vm } from "forge-std/Vm.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { VRFCoordinatorV2Mock } from "../../script/Interactions.s.sol";
import {CreateSubscription } from "../../script/Interactions.s.sol";

contract RaffleTest is StdCheats, Test {
    /*Errors */
    event RequestedRaffleWinner(uint256 indexed requestId);
    event RaffleEnter(address indexed player);
    event  WinnerPicked(address indexed player);

    Raffle public raffle;
    HelperConfig public helperConfig;

    uint64 subscriptionId;
    bytes32 gasLane;
    uint256 automationUpdateInterval;
    uint256 raffleEntranceFee;
    uint32 callbackGasLimit;
    address vrfCoordinatorV2;

    address public constant PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        vm.deal(PLAYER, STARTING_USER_BALANCE);

        (
            ,
            gasLane,
            automationUpdateInterval,
            raffleEntranceFee,
            callbackGasLimit,
            vrfCoordinatorV2, 
            //deployerKey
            ,
        ) = helperConfig.activeNetworkConfig();
    }

    ///////////////////////////////////
    ////////fullfillRandomWords ///////
    //////////////////////////////////
    
}