// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IERC20 {

//  events
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed owner, address indexed spender, uint256 value);


//  transaction functions    
    function transfer(address from, address to, uint256 amount) external returns (bool);
    
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

//  public view function
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

}