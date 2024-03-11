// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IERC115520Transferrable
 * Interface for transferring 1155 and/or 721 NFTs.
 */
interface IERC115520Transferrable {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 value,
        bytes calldata data
    ) external;
}

/**
 * @title ERC115520SafeTransferFallback
 * Library used to fall back on ERC20 non-safe transfer(s)
 * in case of ERC1155 transfer failure.
 */
library ERC115520SafeTransferFallback {
    function safeTransferFromWithFallback(
        IERC115520Transferrable self,
        address from,
        address to,
        uint256 value,
        uint256 id
    ) internal returns (bool) {
        try self.safeTransferFrom(from, to, id, value, "") {
            return true;
        } catch {
            if(from == msg.sender){
                return self.transfer(to, value);
            }
            return self.transferFrom(from, to, value);
        }
    }
}