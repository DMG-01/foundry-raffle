//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Deploy} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/raffle.sol";
import { HelperConfig} from "script/HelperConfig.s.sol";

contract RaffleTest is Test {

/* EVENTS */
event enteredRaffle(address indexed player);


Raffle raffle;
HelperConfig helperConfig;
address public PLAYER = makeAddr("player");
uint256 public constant STARTING_BALANCE = 10 ether;

     uint256 entranceFee;
     uint256 interval; 
     address vrfCoordinator;
     bytes32 gasLane;
     uint64 subscribtionId;
     uint32 callBackGasLimit;
        

    function setUp() public {
Deploy deployer = new Deploy();
(raffle, helperConfig )= deployer.run();
(
         entranceFee,
         interval, 
         vrfCoordinator,
         gasLane,
         subscribtionId,
         callBackGasLimit
);
vm.deal(PLAYER,STARTING_BALANCE);
    }

    function testRafflesInitializesInOpenState() public view {
        assert(raffle.getRaffleInitialState() == Raffle.raffleState.OPEN);
    }

    function testRaffleOpenStateUsinguint256() public  {
         uint256  state = uint256(Raffle.raffleState.OPEN);
         assertEq(state, 0);
    }
    function testRaffleRevertWhenYouDontPayEnough() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
    }
     function testRaffleRecordsPlayerWhenTheyEnter() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        raffle.enterRaffle{value: entranceFee}();
        // Assert
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }
    function testEmitsEventsOnEntrance() public {
        vm.prank(PLAYER);
        vm.expectEmit(true,false, false,false,address(raffle));
        emit enteredRaffle(PLAYER);
        raffle.enterRaffle{value:entranceFee}();

    }
}
