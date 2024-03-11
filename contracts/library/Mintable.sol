
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

abstract contract Mintable721 {
    //ownership, approve for minting
    address public _owner;
    mapping(address => bool) internal mintApproved;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function setOwner(address newOwner) onlyOwner external {
        _owner = newOwner;
    }
    
    function approveForMinting(address _approver, bool status) onlyOwner external {
        mintApproved[_approver] = status;
    }

    function mint(address account, uint256 tokenId, bytes memory data) external {
        require(mintApproved[msg.sender], "Account is not mint approved");
        // _safeMint(account, tokenId, "");
    }
}