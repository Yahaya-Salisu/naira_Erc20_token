// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import "../src/RoseCoin.sol";

contract RoseCoinTest is Test {
    RoseCoin public rosecoin;
    address public owner;
    address public User1;

    function setUp() public {
        rosecoin = new RoseCoin();
    }

     function test_mint() public {
        uint256 amount = 1000e18;
        vm.startPrank(User1);
        vm.expectRevert();
        rosecoin.mint(User1, amount);
        assertEq(rosecoin.balanceOf(User1), 0);
        }
}