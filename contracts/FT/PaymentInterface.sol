//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC20.sol";

contract PaymentInterface is IERC20 {

//  events
    event PI_AtemptToUpdateSupply( address from );
    event PI_SupplyAltered( uint256 newSupply, uint256 change );
    event PI_AttemptToapprove(address sender, address spender);
    event PI_AllowanceSpent(address owner, address spender, uint256 amount);
    event PI__attemptToSpendAllowances(address owner, address spender, uint256 amount);

//  immutables
    address immutable private i_owner;


//  errors
    error PI__invalidAddress(address invalidEntry);
    error PI__attemptToOverspendAllowances(address owner, address spender);

//  modifiers
    modifier authorizedPesonnelOnly() {
        require(msg.sender == i_owner, "PI__trespassing");
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
    function mintCoins(uint256 amount) public authorizedPesonnelOnly{
        address _sender = msg.sender;
        emit PI_AtemptToUpdateSupply( _sender );
        TotalSupply += amount;
        balances[ i_owner ] += amount;
        emit PI_SupplyAltered( TotalSupply, amount );
        
    }

    function burnCoins(uint256 amount) public authorizedPesonnelOnly {
        address _sender = msg.sender;
        emit PI_AtemptToUpdateSupply( _sender );
        if(_sender == address(0)) revert PI__invalidAddress(_sender);
        
        TotalSupply -= amount;
        balances[_sender] -= amount;
        emit PI_SupplyAltered( TotalSupply, amount );
        
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        bool success = false;

        if(to == address(0)) {
            revert PI__invalidAddress(to);
        }

        else if(from == address(0)) {
            revert PI__invalidAddress(from);
        }

        else {
            
            if(msg.sender == from) {
                unchecked {
                balances[ from ] -= amount;
                balances[ to ] += amount;
                } 
            }
            else {
                unchecked {
                balances[ from ] -= amount;
                balances[ to ] += amount;
                spendAllowances(from, msg.sender, amount);
                success = true;
            }
            }
            success = true;
            emit Transfer(
                from, to, amount
            );
        }
        return success;
    }

    function approve(address spender, uint256 amount) public override returns(bool){
        address sender = msg.sender;
        bool success = false;
        emit PI_AttemptToapprove(sender, spender);
        if(spender == address(0)) revert PI__invalidAddress(spender);

        allowances[sender][spender] += amount;
        success = true; 
        
        emit Approval(sender, spender, allowances[sender][spender]);
        return success;
    }

    function transfer(address to, uint256 amount) external override returns (bool){
        bool success = false;
        if(to == address(0)) revert PI__invalidAddress(to);

        success = transferFrom(msg.sender, to, amount);

        return success;
    
    }
    
    function spendAllowances(address owner, address spender, uint256 amount) public {
        uint256 _allowance = allowances[owner][spender];
        
        emit PI__attemptToSpendAllowances(owner, spender, amount);
        if(msg.sender != owner) {
            require(allowances[owner] [msg.sender] >= 0, "PI__NotEnoughAllowances");
        }
        if(amount > _allowance) revert PI__attemptToOverspendAllowances(owner, spender);

        allowances[owner][spender] -= amount;

        emit PI_AllowanceSpent(owner, spender, amount);

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