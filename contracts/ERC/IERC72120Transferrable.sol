// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IERC1155721Transferrable
 * Interface for transferring 1155 and/or 721 NFTs.
 */
interface IERC72120Transferrable {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

/**
 * @title ERC1155721SafeTransferFallback
 * Library used to fall back on ERC721 non-safe transfer(s)
 * in case of ERC20 transfer failure.
 */
library ERC72120SafeTransferFallback {
    function safeTransferFromWithFallback(
        IERC72120Transferrable self,
        address from,
        address to,
        uint256 value,
        uint256 maxEntrants
    ) internal {
        try self.transferFrom(from, to, value)  {} catch {
            for (uint256 i = value; i < value + maxEntrants; ++i) {
                self.transferFrom(from, to, i);
            }
        }
    }
}