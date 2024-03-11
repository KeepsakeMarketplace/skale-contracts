pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED
interface IERC20Nested {
    function totalSupply(address token) external view returns (uint256);
    function balanceOf(address token, address account) external view returns (uint256);
    function transfer(address token, address recipient, uint256 amount) external returns (bool);
    function allowance(address token, address owner, address spender) external view returns (uint256);
    function approve(address token, address spender, uint256 amount) external returns (bool);
    function transferFrom(address token, address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address token, address indexed from, address indexed to, uint256 value);
    event Approval(address token, address indexed owner, address indexed spender, uint256 value);
}
