// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";
import "../src/RoseCoin.sol";

contract deployRSC is Script {
    RoseCoin public roseCoin;

    function run() public {
        
        vm.startBroadcast();
        roseCoin = new RoseCoin();
        vm.stopBroadcast();
    }
}