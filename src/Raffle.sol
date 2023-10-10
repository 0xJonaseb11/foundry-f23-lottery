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

        function enterRaffle() external payable {
            require(msg.value >= i_entranceFee, "Not Enough ETH");

            //Effective way
            if (msg.value < i_entranceFee) {
                revert Raffle__NotEnoughEthSent();
            }
            if (s_raffleState != RaffleState.OPEN) {
                revert Raffle__RaffleNotOpen();
            }
            s_players.push(payable(msg.sender));
            emit EnteredRaffle(msg.sender);
        }

        function checkUpkeep(bytes memory /**CheckData */
        ) public view returns(bool upkeepNeeded, bytes memory /**performData */) {
            bool timeHasPassed = (block.timestamp - s_lastTimestamp) >= i_interval;
            bool isOpen = RaffleState.OPEN == s_raffleState;
            bool hasBalance = address(this).balance > 0;
            bool hasPlayers = s_players.length > 0;
            upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);

            return (upkeepNeeded, "0x0");
        }

        /**getting a random winner */
        function performUpkeep(bytes /**performData */) external {
            (bool upkeepNeeded, ) = checkUpkeep("");
            if (!upkeepNeeded) {
                revert Raffle__NoUpkeepNeeded();
            }
            /**Check if enough time has passed */
            if ((block.timestamp - lastTimestamp) > i_interval) {
                revert Raffle__TransferFailed(
                    address(this).balance, s_players.length, uint256(s_raffleState)
                );
            }
            s_raffleState = RaffleState.CALCULATING;

            //Get a winner
            uint256 requestId = i_vrfCoordinator.requestRandomWords(
                i_gasLane, i_subscriptionId,
                REQUEST_CONFIRMATIONS, i_callbackGasLimit , NUM_WORDS
            );

            emit RequestedRaffleWinner(requestId);
        }

        function fullfillRandomWords(uint256 /**requestId */, uint256[] memory randomWords) internal override {
            //Effects
            uint256 indexOfWinner = randomWords[0] % s_players.length;
            address payable winner = s_players[indexOfWinner];
            s_recentWinner = winner;
            s_raffleState = RaffleState.OPEN;
        }



}