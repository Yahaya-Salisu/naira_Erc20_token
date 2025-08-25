// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import "../src/RoseCoin.sol";

contract RoseCoinTest is RoseCoin, Test {
    RoseCoin public rosecoin;
    address public owner;
    address public User1;
    
    function setUp() public {
        rosecoin = new RoseCoin();
        owner = address(this);
        User1 = makeAddr("User1");
    }

    function test_deposit() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(User1);
        rosecoin.deposit(User1, amount);
        assertEq(rosecoin.balanceOf(User1), amount);
    }

    function test_deposit_zero_amount() external whenNotPaused {
        uint256 amount = 0;
        vm.prank(User1);
        vm.expectRevert();
        rosecoin.deposit(User1, amount);
        assertEq(rosecoin.balanceOf(User1), 0);
    }

    function test_deposit_whenPaused() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        rosecoin.pause();
        vm.prank(User1);
        vm.expectRevert();
        rosecoin.deposit(User1, amount);
        assertEq(rosecoin.balanceOf(User1), 0);
    }

    function test_mint() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        rosecoin.mint(User1, amount);
        assertEq(rosecoin.balanceOf(User1), amount);
    }

     function test_mint_by_non_owner() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(User1);
        vm.expectRevert();
        rosecoin.mint(User1, amount);
        assertEq(rosecoin.balanceOf(User1), 0);
    }

    function test_mint_zero_amount() external whenNotPaused {
        uint256 amount = 0;
        vm.prank(owner);
        vm.expectRevert();
        rosecoin.mint(User1, amount);
        assertEq(rosecoin.balanceOf(User1), 0);
    }

    function test_mint_whenPaused() external {
        uint256 amount = 1000e18;
        vm.startPrank(owner);
        rosecoin.pause();
        vm.expectRevert();
        rosecoin.mint(User1, amount);
        assertEq(rosecoin.balanceOf(User1), 0);
        vm.stopPrank();
    }

    function test_mint_exceeeds_supplyCap() external whenNotPaused {
        uint256 amount = supplyCap + 1;
        vm.prank(owner);
        vm.expectRevert();
        rosecoin.mint(User1, amount);
        assertEq(rosecoin.balanceOf(User1), 0);
    }

    function test_mint_to_address_zero() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        vm.expectRevert();
        rosecoin.mint(address(0), amount);
        assertEq(rosecoin.balanceOf(User1), 0);
    }
}