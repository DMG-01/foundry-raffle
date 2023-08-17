//SPDX-License-Identifier:MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions
pragma solidity ^0.8.18;
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


contract Raffle is VRFConsumerBaseV2{
error Raffle__notEnoughEthSent();
error Raffle__transferFailed();
error Raffle__raffleNotOpen();
error Raffle__upKeepNotNeeded(uint256 currentBalance,uint256 numberOfPlayers,uint256 raffleState);

enum raffleState {
    OPEN,
    CALCULATING
}

uint16 private constant REQUEST_CONFIRMATIONS = 2;
uint32 private constant NUM_WORD = 1;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
   VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callBackGasLimit;
    address payable[] private s_players;
    raffleState private s_raffleState; 
    address private recentWinner;
    
    uint256 private s_lastTimeStamp;

event enteredRaffle(address indexed player);
event pickedWinner(address indexed winner );


    constructor(
        uint256 entranceFee,
     uint256 interval, 
     address vrfCoordinator,
      bytes32 gasLane,
       uint64 subscribtionId,
        uint32 callBackGasLimit)
        VRFConsumerBaseV2(vrfCoordinator)
        
         {
   i_entranceFee = entranceFee;
   i_interval = interval;
   i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
   i_gasLane =gasLane;
   i_subscriptionId = subscribtionId;
   i_callBackGasLimit = callBackGasLimit;
   s_lastTimeStamp = block.timestamp;
   s_raffleState = raffleState.OPEN;
   
    }

    function enterRaffle() external payable {
        if(msg.value < i_entranceFee){
            revert Raffle__notEnoughEthSent();
        }
        if(s_raffleState != raffleState.OPEN){
            revert Raffle__raffleNotOpen();
        }
        s_players.push(payable(msg.sender)); 
        emit enteredRaffle(msg.sender);
    }

    function checkUpKeep(bytes memory /* */ ) public view returns(bool upKeepNeeded, bytes memory /*perform data*/){
       bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >=  i_interval;
       bool isOpen = raffleState.OPEN == s_raffleState;
       bool hasPlayers = s_players.length > 1;
       bool hasBalance = address(this).balance > 0;
       upKeepNeeded = (timeHasPassed && isOpen && hasPlayers && hasBalance );
       return(upKeepNeeded,"0x0");
    }

    function performUpkeep(bytes memory /*perform data*/)  external {
        (bool upKeepNeeded,) = checkUpKeep("");
        if(!upKeepNeeded){
            revert Raffle__upKeepNotNeeded(
             address(this).balance,
             s_players.length,
             uint256(s_raffleState)
            );
        }
        s_raffleState = raffleState.CALCULATING;
        /*uint256 requestId =*/ i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callBackGasLimit,
            NUM_WORD
        );
        
    }
    
    function fulfillRandomWords( 
        uint256 /*requestId*/,
        uint256[] memory randomWords
    )
    internal override
    {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        recentWinner = winner;
        s_raffleState = raffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit pickedWinner(winner); 
        (bool success,) = recentWinner.call{value:address(this).balance}("");
        if(!success){
            revert Raffle__transferFailed();
        }
        
    }

    /* getter functions*/
    function getEntranceFee()view external returns(uint256) {
        return i_entranceFee;
    }
}