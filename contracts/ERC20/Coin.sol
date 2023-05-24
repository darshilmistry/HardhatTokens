//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC20.sol";

contract Coin is IERC20 {

//  events
    event Coin_AtemptToUpdateSupply( address from );
    event Coin_SupplyAltered( uint256 newSupply, uint256 change );
    event Coin_AttemptToapprove(address sender, address spender);
    event Coin_AllowanceSpent(address owner, address spender, uint256 amount);

//  immutables
    address immutable private i_owner;


//  errors
    error Coin__invalidAddress(
        address invalidEntry
    );
    error Coin__trespassing();
    error Coin__attemptToOverspendAllowances(address owner, address spender);

//  modifiers
    modifier authorizedPesonnelOnly() {
        if(msg.sender != i_owner) revert Coin__trespassing();
        _;
    }

//  mappings
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

//  variables
    uint256 private TotalSupply;
    string name;
    string symbol;
    uint8 decimals = 18;


//  constructor
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        i_owner = msg.sender;
    }

//  transaction functions
    function mintCoin(uint256 amount) public authorizedPesonnelOnly{
        address _sender = msg.sender;
        emit Coin_AtemptToUpdateSupply( _sender );
        TotalSupply += amount;
        balances[ i_owner ] += amount;
        emit Coin_SupplyAltered( TotalSupply, amount );
        
    }

    function burnCoins(uint256 amount) public authorizedPesonnelOnly {
        address _sender = msg.sender;
        emit Coin_AtemptToUpdateSupply( _sender );
        if(_sender == address(0)) revert Coin__invalidAddress(_sender);
        
        TotalSupply -= amount;
        balances[_sender] -= amount;
        emit Coin_SupplyAltered( TotalSupply, amount );
        
    }

    function transfer(address from, address to, uint256 amount) public returns(bool) {
        bool success = false;
        if(to == address(0)) {
            revert Coin__invalidAddress(to);
        }
        else {
            unchecked {
                balances[ from ] -= amount;
                balances[ to ] += amount;
                success = true;
            }
            emit Transfer(
                from, to, amount
            );
        }
        return success;
    }

    function approve(address spender, uint256 amount) public returns(bool){
        address sender = msg.sender;
        bool success = false;
        emit Coin_AttemptToapprove(sender, spender);
        if(spender == address(0)) revert Coin__invalidAddress(spender);

        allowances[sender][spender] = amount;
        success = true; 
        
        emit Approval(sender, spender, amount);
        return success;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        bool success = false;
        if(from == address(0)) revert Coin__invalidAddress(from);
        if(to == address(0)) revert Coin__invalidAddress(to);

        spendAllowances(from, msg.sender, amount);
        transfer(from, to, amount);
        success = true;

        return success;
    
    }
    
    function spendAllowances(address owner, address spender, uint256 amount) public {
        uint256 _allowance = allowances[owner][spender];

        if(amount > _allowance) revert Coin__attemptToOverspendAllowances(owner, spender);

        allowances[owner][spender] -= amount;

        emit Coin_AllowanceSpent(owner, spender, amount);

    }


//  public view/pure function

    function whoIsOwner() public view returns(address) {
        return i_owner;
    }

    function totalSupply() public view override returns (uint256) {
        return TotalSupply;
    }

    function balanceOf(address account) public view override returns(uint256) {
        return balances[account];
    }

    
    function allowance(address owner, address spender) public override view returns (uint256) {
        return allowances[owner][spender];
    }

}