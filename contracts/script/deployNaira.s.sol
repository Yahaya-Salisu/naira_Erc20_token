// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";
import "../src/nairaToken.sol";

contract deployNaira is Script {
    nairaToken public naira;

    function run() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        vm.startBroadcast();
        naira = new nairaToken();
        vm.stopBroadcast();
    }
}