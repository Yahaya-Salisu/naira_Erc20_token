// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract RoseCoin {
    string public name = "RoseCoin";
    string public symbol = "RSC";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public supplyCap = 100_000e18;
    address private owner;
    bool public paused;

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
        require(msg.sender == owner, "Erc20: Not owner");
        _;
    }


    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    /////////////////////////////////////
    //      EXTERNAL FUNCTIONS         //
    /////////////////////////////////////

    function pause() external onlyOwner {
        paused = true;
        emit contractPaused();
    }

    function unpause() external onlyOwner {
        paused = false;
        emit contractUnpaused();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
        emit ownershipTransfered(newOwner);
    }

    function deposit(address to, uint256 depositAmount) external whenNotPaused {
        if (depositAmount > 0 && totalSupply + depositAmount <= supplyCap){
            _deposit(to, depositAmount);
        }
    }

    function mint(address to, uint256 mintAmount) external onlyOwner whenNotPaused {
        if (to == address(0)){
            revert("Erc20: Address Zero");
        }

        if (mintAmount != 0 && totalSupply + mintAmount <= supplyCap){
        _mint(to, mintAmount);
        }
    }

    function burn(address from, uint256 burnAmount) external onlyOwner whenNotPaused {
         if (from == address(0)){
            revert("Erc20: Address Zero");
        }

        if (burnAmount != 0 && burnAmount <= balanceOf[from]){
            _burn(from, burnAmount);
        }
    }

    function transfer(address from, address to, uint256 transferAmount) external whenNotPaused {
        if (from == address(0) || to == address(0)){
            revert("Erc20: Address Zero");
            }

        if (transferAmount != 0 && transferAmount <= balanceOf[from]){
            _transfer(from, to, transferAmount);
        }
    }

    function transferFrom(address from, address to, uint256 transferAmount) external whenNotPaused {
    require(from != address(0) && to != address(0), "Erc20: Address zero");
    require(transferAmount > 0, "Erc20: Zero spendAmount");
    require(allowances[from][msg.sender] >= transferAmount, "Erc20: Insufficient allowance");
    require(balanceOf[from] >= transferAmount, "Erc20: Insufficient balance");

    allowances[from][msg.sender] -= transferAmount;
    _transfer(from, to, transferAmount); 
}

    function approve(address spender, uint256 approveAmount) external whenNotPaused {
        if (spender != address(0)){
            _approve(spender, approveAmount);
        }
    }

    function withdraw(address from, uint256 withdrawAmount) external whenNotPaused {
        require(withdrawAmount > 0 && withdrawAmount <= balanceOf[from], "Erc20: Invalid Amount");
            _withdraw(from, withdrawAmount);
    }

    /////////////////////////////////////
    //         VIEW FUNCTIONS          //
    /////////////////////////////////////

    function allowance(address _owner, address spender) external view returns(uint256) {
        return allowances[_owner][spender];
    }

    function getBalance(address user) external view returns(uint256) {
        return balanceOf[user];
    }


    /////////////////////////////////////
    //      INTERNAL FUNCTIONS         //
    /////////////////////////////////////

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