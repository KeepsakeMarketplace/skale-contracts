
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// SPDX-License-Identifier: UNLICENSED
interface IERC20Mintable is IERC20 {
    function mint(address account, uint256 amount) external;
}
