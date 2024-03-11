// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Mintable is IERC721 {
    function mint(address account, uint256 tokenId, bytes calldata data) external;
}