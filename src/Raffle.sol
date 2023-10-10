// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { VRFCoordinatorV2Interface } from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import { VRFConsumerBaseV2 } from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Raffle is VRFConsumerBaseV2 {

    error Raffle__NotEnoughEthSent();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__NoUpKeepNeeded(
        uint256 currentBalance, uint256 numPlayers, 
        RaffleState raffleState
    );

    /**Type declaration */
    enum RaffleState { OPEN, CALCULATING}

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    address payable[] private s_players;
    uint256 private s_lastTimestamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    event EnteredRaffle(uint256 indexed player);
    event PickedWinner(uint256 indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestId);

    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator, bytes32 gasLane,
        uint256 subscriptionId, uint32 callbackGasLimit) VRfConsumerBaseV2(vrfcoordinator) {
            i_entranceFee = entranceFee;
            i_interval = interval;
            s_lastTimestamp = block.timestamp;
            i_vrfCoordinator = vrfCoordinator;
            i_gasLane = gasLane;
            i_subscriptionId = subscriptionId;
            i_callbackGasLimit = callbackGasLimit;

            s_raffleState = RaffleState.OPEN;
        }

        function 



}