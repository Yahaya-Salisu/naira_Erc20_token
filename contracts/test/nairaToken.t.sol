// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import "../src/nairaToken.sol";

contract nairaTokenTest is nairaToken, Test {
    nairaToken public naira;
    address public owner;
    address public newOwner;
    address public User1;
    address public User2;
    
    function setUp() public {
        naira = new nairaToken();
        owner = address(this);
        User1 = makeAddr("User1");
        User2 = makeAddr("User2");
        newOwner = makeAddr("newOwner");
    }

    function test_transferOwnership() external whenNotPaused {
        vm.prank(owner);
        naira.transferOwnership(newOwner);
        owner = newOwner;
    }

    function test_transferOwnership_revert_whenPaused() external {
        vm.startPrank(owner);
        naira.pause();
        vm.expectRevert();
        naira.transferOwnership(newOwner);
        owner = newOwner;
        vm.stopPrank();
    }

    function test_transferOwnership_to_address_zero_revert() external whenNotPaused {
        vm.prank(owner);
        vm.expectRevert();
        naira.transferOwnership(address(0));
        owner = address(0);
    }

    function test_pause() external whenNotPaused {
        vm.prank(owner);
        naira.pause();
    }

    function test_unpause() external {
        vm.prank(owner);
        naira.unpause();
    }

    function test_pause_by_non_owner() external whenNotPaused {
        vm.prank(User1);
        vm.expectRevert();
        naira.pause();
    }

    function test_unpause_by_non_owner() external {
        vm.prank(User1);
        vm.expectRevert();
        naira.unpause();
    }

    function test_deposit() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(User1);
        naira.deposit(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
    }

    function test_deposit_zero_amount() external whenNotPaused {
        uint256 amount = 0;
        vm.prank(User1);
        vm.expectRevert();
        naira.deposit(User1, amount);
        assertEq(naira.balanceOf(User1), 0);
    }

    function test_deposit_whenPaused() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        naira.pause();
        vm.prank(User1);
        vm.expectRevert();
        naira.deposit(User1, amount);
        assertEq(naira.balanceOf(User1), 0);
    }

    function test_mint() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
    }

     function test_mint_by_non_owner() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(User1);
        vm.expectRevert();
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), 0);
    }

    function test_mint_zero_amount() external whenNotPaused {
        uint256 amount = 0;
        vm.prank(owner);
        vm.expectRevert();
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), 0);
    }

    function test_mint_whenPaused() external {
        uint256 amount = 1000e18;
        vm.startPrank(owner);
        naira.pause();
        vm.expectRevert();
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), 0);
        vm.stopPrank();
    }

    function test_mint_exceeeds_supplyCap() external whenNotPaused {
        uint256 amount = supplyCap + 1;
        vm.prank(owner);
        vm.expectRevert();
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), 0);
    }

    function test_mint_to_address_zero() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        vm.expectRevert();
        naira.mint(address(0), amount);
        assertEq(naira.balanceOf(address(0)), 0);
    }

    function test_burn() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.startPrank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        naira.burn(User1, amount);
        assertEq(naira.balanceOf(User1), 0);
        vm.stopPrank();
    }

     function test_burn_by_non_owner() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        vm.prank(User1);
        vm.expectRevert();
        naira.burn(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
    }

    function test_burn_zero_amount() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.startPrank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        vm.expectRevert();
        naira.burn(User1, 0);
        assertEq(naira.balanceOf(User1), amount);
    }

    function test_burn_whenPaused() external {
        uint256 amount = 1000e18;
        vm.startPrank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        naira.pause();
        vm.expectRevert();
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        vm.stopPrank();
    }

    function test_burn_revert_if_exceeeds_userBalance() external whenNotPaused {
        uint256 amount = 1000e18;
        uint256 overAmount = 1100e18;
        vm.startPrank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        vm.expectRevert();
        naira.burn(User1, overAmount);
        assertEq(naira.balanceOf(User1), amount);
        vm.stopPrank();
    }

    function test_transfer() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);

        vm.prank(User1);
        naira.transfer(User1, User2, amount);
        assertEq(naira.balanceOf(User2), amount);
    }

    function test_transfer_to_zero_address() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);

        vm.prank(User1);
        vm.expectRevert();
        naira.transfer(User1, address(0), amount);
        assertEq(naira.balanceOf(address(0)), 0);
    }

    function test_transfer_zero_amount() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);

        vm.prank(User1);
        vm.expectRevert();
        naira.transfer(User1, User2, 0);
        assertEq(naira.balanceOf(User2), 0);
    }

    function test_transfer_whenPaused() external {
        uint256 amount = 1000e18;
        vm.startPrank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        naira.pause();
        vm.stopPrank();

        vm.prank(User1);
        vm.expectRevert();
        naira.transfer(User1, User2, amount);
        assertEq(naira.balanceOf(User2), 0);
    }

    function test_transfer_revert_if_exceeeds_userBalance() external whenNotPaused {
        uint256 amount = 1000e18;
        uint256 overAmount = 1100e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);

        vm.prank(User1);
        vm.expectRevert();
        naira.transfer(User1, User2, overAmount);
        assertEq(naira.balanceOf(User2), 0);
    }

    function test_approve_and_transferFrom() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);

        vm.prank(User1);
        naira.approve(User2, amount);

        vm.prank(User2);
        naira.transferFrom(User1, User2, amount);
        assertEq(naira.balanceOf(User2), amount);
    }

    function test_approve_and_transferFrom_revert_if_zero_amount() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);

        vm.prank(User1);
        naira.approve(User2, 0);

        vm.prank(User2);
        vm.expectRevert();
        naira.transferFrom(User1, User2, 0);
        assertEq(naira.balanceOf(User2), 0);
    }

    function test_approve_and_transferFrom_revert_if_insufficient_userBalance() external whenNotPaused {
        uint256 amount = 1000e18;
        uint256 overAmount = 1100e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);

        vm.prank(User1);
        naira.approve(User2, overAmount);

        vm.prank(User2);
        vm.expectRevert();
        naira.transferFrom(User1, User2, overAmount);
        assertEq(naira.balanceOf(User2), 0);
    }

    function test_approve_and_transferFrom_revert_if_insufficient_allowance() external whenNotPaused {
        uint256 amount = 1000e18;
        uint256 _amount = 500e18;
        uint256 overAmount = 700e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);

        vm.prank(User1);
        naira.approve(User2, _amount);

        vm.prank(User2);
        vm.expectRevert();
        naira.transferFrom(User1, User2, overAmount);
        assertEq(naira.balanceOf(User2), 0);
    }

    function test_approve_and_transferFrom_revert_if_to_is_address_zero() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);

        vm.prank(User1);
        naira.approve(User2, amount);

        vm.prank(User2);
        vm.expectRevert();
        naira.transferFrom(User1, address(0), amount);
        assertEq(naira.balanceOf(address(0)), 0);
    }

    function test_approve_revert_if_spender_is_address_zero() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.prank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);

        vm.prank(User1);
        vm.expectRevert();
        naira.approve(address(0), amount);
        assertEq(naira.balanceOf(address(0)), 0);
    }

    function test_withdraw() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.startPrank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        vm.stopPrank();
        vm.startPrank(User1);
        naira.withdraw(User1, amount);
        assertEq(naira.balanceOf(User1), 0);
        vm.stopPrank();
    }

    function test_withdraw_zero_amount() external whenNotPaused {
        uint256 amount = 1000e18;
        vm.startPrank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        vm.stopPrank();
        vm.startPrank(User1);
        vm.expectRevert();
        naira.withdraw(User1, 0);
        assertEq(naira.balanceOf(User1), amount);
    }

    function test_withdraw_whenPaused() external {
        uint256 amount = 1000e18;
        vm.startPrank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        naira.pause();
        vm.stopPrank();
        vm.startPrank(User1);
        vm.expectRevert();
        naira.withdraw(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        vm.stopPrank();
    }

    function test_withdraw_revert_if_exceeeds_userBalance() external whenNotPaused {
        uint256 amount = 1000e18;
        uint256 overAmount = 1100e18;
        vm.startPrank(owner);
        naira.mint(User1, amount);
        assertEq(naira.balanceOf(User1), amount);
        vm.stopPrank();
        vm.startPrank(User1);
        vm.expectRevert();
        naira.withdraw(User1, overAmount);
        assertEq(naira.balanceOf(User1), amount);
        vm.stopPrank();
    }
}