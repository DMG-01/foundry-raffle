//SPDX-License-Identifier:MIT

pragma solidity ^ 0.8.18;

import { Script } from "forge-std/Script.sol";
import { Raffle }  from "src/raffle.sol";
import { HelperConfig } from "script/HelperConfig.s.sol";

contract Deploy  is Script{
Raffle RaffleDeploy;

function run() external returns(Raffle, HelperConfig){

HelperConfig helperConfig = new HelperConfig();
(uint256 entranceFee,
     uint256 interval, 
     address vrfCoordinator,
      bytes32 gasLane,
       uint64 subscribtionId,
        uint32 callBackGasLimit
        ) = helperConfig.activeNetworkConfig(); 

        vm.startBroadcast();
    Raffle raffle = new Raffle(
        entranceFee,
        interval,
        vrfCoordinator,
        gasLane,
        subscribtionId,
        callBackGasLimit
    );
        vm.stopBroadcast();
      return(raffle, helperConfig);
}
}   