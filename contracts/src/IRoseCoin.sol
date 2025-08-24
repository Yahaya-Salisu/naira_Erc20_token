// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./RoseCoin.sol";

interface IRoseCoin {

    function pause() external;

    function unpause() external;

    function transferOwnership(address newOwner) external;

    function deposit(address to, uint256 depositAmount) external;

    function mint(address to, uint256 mintAmount) external;

    function burn(address from, uint256 burnAmount) external;

    function transfer(address from, address to, uint256 transferAmount) external;

    function transferFrom(address from, address to, uint256 spendAmount) external;

    function approve(address spender, uint256 approveAmount) external;

    function withdraw(address from, uint256 withdrawAmount) external;

    function allowance(address _owner, address spender) external view returns(uint256);

    function getBalance(address user) external view returns(uint256);
}