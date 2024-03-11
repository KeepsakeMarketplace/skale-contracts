// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './MarketStorage.sol';

contract MarketProxy is MarketStorage {

    function setLogicContract(address _c) external onlyCommander returns (bool success){
        logic_contract = _c;
        return true;
    }

    constructor(address _logic_contract) {
        logic_contract =  _logic_contract;
        _requiredOwnerships.push(RequiredOwnership(_msgSender(), 0, _msgSender()));
    }

    fallback () payable external {
        address target = logic_contract;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), target, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            case 1 { return(ptr, size) }
        }
    }

    function onERC721Received(address /* operator */, address /* from */, uint256 /* tokenId */, bytes calldata /* data */) external returns(bytes4) {
        address target = logic_contract;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), target, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            case 1 { return(ptr, size) }
        }
        return(0x150b7a02);
    }

    function onERC1155Received(address /* operator */, address /* from */, uint256 /* id */, uint256 /* value */, bytes calldata /* data */) external returns(bytes4) {
        address target = logic_contract;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), target, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            case 1 { return(ptr, size) }
        }
        return 0xf23a6e61;
    }
}