pragma solidity ^0.8.0;

interface IEtherbase {
    receive() external payable;
    function retrieve(address payable receiver) external;
    function partiallyRetrieve(address payable receiver, uint amount) external;
}

contract EtherbaseUsage {

    uint256 MIN_AMOUNT = 1000000000000000;
    bool _enabled = false;

    modifier topUp {
        if (_enabled && msg.sender.balance < MIN_AMOUNT) {
            partiallyRetrieve(payable(msg.sender), MIN_AMOUNT);
        }
        _;
    }

    function retrieve(address payable receiver) public {
        getEtherbase().retrieve(receiver);
    }

    function partiallyRetrieve(address payable receiver, uint amount) public {
        getEtherbase().partiallyRetrieve(receiver, amount);
    }

    function enable(bool status) internal {
        _enabled = status;
    }
    
    function sendToEtherbase() public payable {
        getEtherbaseAddress().transfer(msg.value);
    }

    function getEtherbase() public pure returns (IEtherbase) {
        return IEtherbase(getEtherbaseAddress());
    }

    function getEtherbaseAddress() public pure returns (address payable) {
        return payable(0xd2bA3e0000000000000000000000000000000000);
    }
}