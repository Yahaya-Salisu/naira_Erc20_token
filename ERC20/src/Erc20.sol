```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Erc20 {
    string public name;
    string public symbol;
    uint256 public decimal;
    uint256 totalSupply;
    uint256 public supplyCap;
    address private owner;

    event deposited(address to, uint256 depositAmount);
    event minted(address to, uint256 mintAmount);
    event burned(address from, address to, uint256 burnAmount);
    event transfered(address from, address to, uint256 transferAmount);
    event approved(address owner, address spender, uint256 approveAmount);
    event withdrawn(address from, uint256 withdrawAmount);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowances;
    
    constructor() {
        name = "Real Rose";
        symbol = "RRS";
        decimal = 18;
        supplyCap = 100_000e18;
    }

    modifier onlyOwner(){
        if (msg.sender != owner) {
            revert("Erc20: Not owner");
            _;
        }
    }

    /////////////////////////////////////
    //      EXTERNAL FUNCTIONS         //
    /////////////////////////////////////


    function deposit(address to, uint256 depositAmount) external {
        if (depositAmount > 0 && totalSupply + depositAmount <= supplyCap){
            _deposit(to, depositAmount);
        }
    }


    function mint(address to, uint256 mintAmount) public onlyOwner {
        if (to == address(0)){
            revert("Erc20: Address Zero");
        }

        if (mintAmount != 0 && totalSupply + mintAmount <= supplyCap){
        _mint(to, mintAmount);
        }
    }

    function burn(address from, uint256 burnAmount) public onlyOwner {
         if (from == address(0)){
            revert("Erc20: Address Zero");
        }

        if (burnAmount != 0 && burnAmount <= balanceOf[from]){
            _burn(from, burnAmount);
        }
    }

    function transfer(address from, address to, uint256 transferAmount) external {
        if (from == address(0) || to == address(0)){
            revert("Erc20: Address Zero");
            }

        if (transferAmount != 0 && transferAmount <= balanceOf[from]){
            _transfer(from, to, transferAmount);
        }
    }

    function approve(address owner, address spender, uint256 approveAmount) external {
        if (owner != address(0) && spender != address(0)){
            _approve(owner, spender, approveAmount);
        }
    }

    function allowance(address owner, address spender, uint256 spendAmount) external view {
        allowances[owner][spender];
    }

    function withdraw(address from, uint256 withdrawAmount) external {
        if (withdrawAmount != 0 && withdrawAmount <= balanceOf[from]){
            _withdraw(from, withdrawAmount);
        }
    }

    function getBalance(address user) external view {
        balanceOf[user];
    }


    /////////////////////////////////////
    //      INTERNAL FUNCTIONS         //
    /////////////////////////////////////

    function _deposit(address to, uint256 depositAmount) internal{
        balanceOf[to] += depositAmount;
        totalSupply += depositAmount;
        emit deposited(to, depositAmount);
    }

    function _mint(address to, uint256 mintAmount) internal {
        balanceOf[to] += mintAmount;
        totalSupply += mintAmount;
        emit minted(to, mintAmount);
    }

    function _burn(address from, uint256 burnAmount) internal {
        balanceOf[from] -= burnAmount;
        totalSupply -= burnAmount;
        emit burned(from, address(0), burnAmount);
    }

    function _transfer(address from, address to, uint256 transferAmount) internal {
        balanceOf[from] -= transferAmount;
        balanceOf[to] += transferAmount;
        emit transfered(from, to, transferAmount);
    }

    function _approve(address owner, address spender, uint256 approveAmount) internal {
        allowances[owner][spender] = approveAmount;
        emit approved(owner, spender, approveAmount);
    }

    function _withdraw(address from, uint256 withdrawAmount) internal {
        balanceOf[from] -= withdrawAmount;
        (bool success, ) = from.call{value: withdrawAmount}("");
        require(success, "Erc20: Withdraw Failed");
        emit withdrawn(from, withdrawAmount);
    }
}
```