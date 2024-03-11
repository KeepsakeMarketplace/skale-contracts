// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../library/BigOwnable.sol";
// import "../library/Etherbase.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MarketStorage is BigOwnable, ReentrancyGuard {  /**, EtherbaseUsage*/
    address public logic_contract;

    event SaleCreated(uint256 indexed marketId, uint256 saleId, address indexed tokenContract, uint256 indexed tokenId, uint256 price, address paymentContract, address creator);
    event SaleFinished(uint256 indexed marketId, uint256 saleId, address indexed tokenContract, uint256 indexed tokenId, uint256 price, address paymentContract, address creator);
    event SaleCancelled(uint256 indexed marketId, uint256 saleId, address indexed tokenContract, uint256 indexed tokenId, uint256 price, address paymentContract, address creator);

    struct TokenSale {
        uint256 tokenId;
        address tokenContract;
        // price per NFT, or all tokens (pirce per token is defined as price / tokenIdFinish)
        uint256 price;
        address paymentContract;
        address payable creator;
        uint64 marketId;
        bool finished;
    }

    struct RequiredOwnership {
        address contractAddress;
        uint256 requiredOwnership;
        address owner;
    }
    // 100 = 1%
    struct Market {
        uint16 cut;
        address payable owner;
    }

    struct TokenContract {
        uint16 cut;
        address payable owner;
    }

    mapping (address => TokenContract) public _marketContracts;

    RequiredOwnership[] public _requiredOwnerships;

    mapping(uint256 => Market) public _markets;

    string public _startError = "startId must be greater than finishId";
    string public _tokenExists = "Token must have a verified owner";
    string public _marketExists = "Market must exist";
    TokenSale[] public _tokenSales;
}