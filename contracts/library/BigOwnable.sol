pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/utils/Context.sol";

contract BigOwnable is Context {
    address private _commander;
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event CommandTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        _commander = _owner;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function commander() public view returns (address) {
        return _commander;
    }
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    modifier onlyCommander() {
        require(_commander == _msgSender(), "Ownable: caller is not the commander");
        _;
    }

    function renounceOwnership() external virtual onlyCommander {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external virtual onlyCommander {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferCommand(address newCommander) external virtual onlyCommander {
        require(newCommander != address(0), "Ownable: new owner is the zero address");
        emit CommandTransferred(_commander, newCommander);
        _commander = newCommander;
    }

    function renounceCommand() external virtual onlyCommander {
        emit CommandTransferred(_commander, address(0));
        _commander = address(0);
    }
}