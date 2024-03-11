pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED
interface IERC20Transfer {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
