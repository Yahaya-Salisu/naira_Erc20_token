// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./INairaToken.sol";

contract nairaToken is INairaToken {
    string public name = "nairaToken";
    string public symbol = "naira";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public supplyCap = 100_000e18;
    address private owner;
    bool public paused;

    error Erc20_not_owner();
    error Erc20_contract_is_paused();
    error Erc20_zero_address();
    error Erc20_zero_amount();
    error Erc20_invalid_amount();
    error Erc20_zero_spendAmount();
    error Erc20_insufficient_allowance();
    error Erc20_insufficient_balance();

    event contractPaused();
    event contractUnpaused();
    event ownershipTransfered(address newOwner);
    event deposited(address to, uint256 depositAmount);
    event minted(address to, uint256 mintAmount);
    event burned(address from, address to, uint256 burnAmount);
    event transfered(address from, address to, uint256 transferAmount);
    event approved(address owner, address spender, uint256 approveAmount);
    event withdrawn(address from, uint256 withdrawAmount);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowances;
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, Erc20_not_owner());
        _;
    }


    modifier whenNotPaused() {
        require(!paused, Erc20_contract_is_paused());
        _;
    }

    //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
    //\/\/\/\/ EXTERNAL FUNCTIONS /\/\/\/\
    //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

    function pause() external onlyOwner {
        paused = true;
        emit contractPaused();
    }

    function unpause() external onlyOwner {
        paused = false;
        emit contractUnpaused();
    }

    function transferOwnership(address newOwner) external onlyOwner whenNotPaused {
        require(newOwner != address(0), Erc20_zero_address());
        owner = newOwner;
        emit ownershipTransfered(newOwner);
    }

    function deposit(address to, uint256 depositAmount) external whenNotPaused {
        if (depositAmount > 0) {
            _deposit(to, depositAmount);
        } else {
            revert("Erc20_zero_amount()");
        }
    }

    function mint(address to, uint256 mintAmount) external onlyOwner whenNotPaused {
        if (to == address(0)){
            revert("Erc20_zero_address()");
        }
        require(mintAmount > 0 && totalSupply + mintAmount <= supplyCap, Erc20_zero_amount());
        _mint(to, mintAmount);
    }

    function burn(address from, uint256 burnAmount) external onlyOwner whenNotPaused {
         if (from == address(0)){
            revert("Erc20_zero_address()");
        }

        require(burnAmount > 0 && burnAmount <= balanceOf[from], Erc20_invalid_amount());
            _burn(from, burnAmount);
    }

    function transfer(address from, address to, uint256 transferAmount) external whenNotPaused {
        require(from != address(0), Erc20_zero_address());
        require(to != address(0), Erc20_zero_address());
        require(transferAmount > 0 && transferAmount <= balanceOf[from], Erc20_invalid_amount());
        _transfer(from, to, transferAmount);
    }

    function transferFrom(address from, address to, uint256 transferAmount) external whenNotPaused {
        require(from != address(0) && to != address(0), Erc20_zero_address());
        require(transferAmount > 0, Erc20_zero_spendAmount());
        require(allowances[from][msg.sender] >= transferAmount, Erc20_insufficient_allowance());
        require(balanceOf[from] >= transferAmount, Erc20_insufficient_balance());

        allowances[from][msg.sender] -= transferAmount;
        _transfer(from, to, transferAmount); 
    }

    function approve(address spender, uint256 approveAmount) external whenNotPaused {
        require(spender != address(0), Erc20_zero_address());
        _approve(spender, approveAmount);
    }

    function withdraw(address from, uint256 withdrawAmount) external whenNotPaused {
        require(withdrawAmount > 0 && withdrawAmount <= balanceOf[from], Erc20_invalid_amount());
            _withdraw(from, withdrawAmount);
    }

    //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
    //\/\/\/\/\/ VIEW FUNCTIONS /\/\/\/\/\
    //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

    function allowance(address _owner, address spender) external view returns(uint256) {
        return allowances[_owner][spender];
    }

    function getBalance(address user) external view returns(uint256) {
        return balanceOf[user];
    }


    //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
    //\/\/\/\/ INTERNAL FUNCTIONS /\/\/\/\
    //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

    function _deposit(address to, uint256 depositAmount) internal{
        balanceOf[to] += depositAmount;
        totalSupply += depositAmount;
        emit deposited(msg.sender, depositAmount);
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

    function _approve(address spender, uint256 approveAmount) internal {
        allowances[msg.sender][spender] = approveAmount;
        emit approved(msg.sender, spender, approveAmount);
    }

    function _withdraw(address from, uint256 withdrawAmount) internal {
        balanceOf[from] -= withdrawAmount;
        totalSupply -= withdrawAmount;
        emit withdrawn(from, withdrawAmount);
    }
}