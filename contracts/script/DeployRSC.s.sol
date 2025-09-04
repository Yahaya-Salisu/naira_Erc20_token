// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";
import "../src/nairaToken.sol";

contract deployRSC is Script {
    nairaToken public nairaToken;

    function run() public {
        
        vm.startBroadcast();
        nairaToken = new nairaToken();
        vm.stopBroadcast();
    }
}