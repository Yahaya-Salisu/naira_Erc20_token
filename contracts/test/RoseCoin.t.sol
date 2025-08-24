// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import "../src/RoseCoin.sol";

contract RoseCoinTest is Test {
    RoseCoin public rosecoin;

    function setUp() public {
        rosecoin = new RoseCoin();
        uint256 amount = 100;
        address User1 = makeAddr(User1);
        address User2 = makeAddr(User2);
    }

    function test_mint() public {}
}