// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import './MarketStorage.sol';

contract Market721 is MarketStorage, IERC721Receiver {

    modifier marketTokenExists(uint256 marketId, address tokenContract) {
        require(_marketContracts[tokenContract].owner != address(0), _tokenExists);
        require(_markets[marketId].owner != address(0), _marketExists);
        _;
    }
    
    modifier marketExists(uint256 marketId) {
        require(_markets[marketId].owner != address(0), _marketExists);
        _;
    }

    // function blacklist(address to, bool status) external onlyOwner {
    //     _blacklist[to] = status;
    // }

    // function enableEtherbase(bool status) external onlyOwner {

    // }

    /** Lets the owner withdraw ETH */
    function rescueFunds() external onlyOwner {
        payable(commander()).transfer(address(this).balance);
    }

    function rescueFunds20(address tokenAddress, uint256 amount) external onlyOwner {
        require(IERC20(tokenAddress).transfer(_msgSender(), amount));
    }
    
    function rescueFunds721(address tokenAddress, uint256 id) external onlyOwner {
        IERC721(tokenAddress).transferFrom(address(this), _msgSender(), id);
    }

    // 100 = 1%, 1000 = 10%
    function setContractOwnerInfo(address contractAddress, address owner, uint16 saleCut, address payable feeReceiver) external /**topUp*/ onlyOwner() {
        _marketContracts[contractAddress] = TokenContract(saleCut, owner, feeReceiver);
    }
    
    function setMarket(uint64 marketId, uint16 cutPercentage, address owner, address payable feeReceiver) external /**topUp*/ onlyOwner {
        _markets[marketId] = Market(cutPercentage, owner, feeReceiver);
    }

    function buy(uint256 saleId, uint256 price) external /**topUp*/ nonReentrant {
        require(saleId < _tokenSales.length);
        TokenSale storage sale = _tokenSales[saleId];
        uint256 amountCost = sale.price;
        // when you go to buy an NFT, you must know the asking price to prevent any sneakyness from occuring
        require(price == amountCost);
        require(!sale.finished);
        sale.finished = true;

        Market memory market = _markets[sale.marketId];
        TokenContract memory tokenContract = _marketContracts[sale.tokenContract];

        IERC721(sale.tokenContract).transferFrom(address(this), _msgSender(), sale.tokenId);

        uint256 tokenContractCut = (amountCost / 10000) * tokenContract.cut;
        uint256 marketOwnerCut =  (amountCost / 10000) *  market.cut;

        IERC20 token = IERC20(sale.paymentContract);
        // give percentage of sale to owner && marketplace owner
        if(tokenContractCut > 0 && tokenContract.feeReceiver != address(0)){
            SafeERC20.safeTransferFrom(token, _msgSender(), tokenContract.feeReceiver, tokenContractCut);
        }
        if(marketOwnerCut > 0){
            SafeERC20.safeTransferFrom(token, _msgSender(), market.feeReceiver, marketOwnerCut);
        }
        if(amountCost > (tokenContractCut + marketOwnerCut)){
            SafeERC20.safeTransferFrom(token, _msgSender(), sale.creator, amountCost - (tokenContractCut + marketOwnerCut));
        }
        emit SaleFinished(sale.marketId, saleId, sale.tokenContract, sale.tokenId, sale.price, sale.paymentContract, sale.creator);
    }

    function cancel(uint256 saleId) external nonReentrant {
        TokenSale storage sale = _tokenSales[saleId];
        require(owner() == _msgSender() || sale.creator == _msgSender());
        require(!sale.finished);
        sale.finished = true;

        IERC721(sale.tokenContract).transferFrom(address(this), _msgSender(), sale.tokenId);

        emit SaleCancelled(sale.marketId, saleId, sale.tokenContract, sale.tokenId, sale.price, sale.paymentContract, sale.creator);
    }
    
    function sell(uint64 marketId, uint256 tokenId, address tokenContract, address paymentContract, uint price) external /**topUp*/ nonReentrant {
        IERC721(tokenContract).transferFrom(_msgSender(), address(this), tokenId);
        _makeSale(
            marketId,
            tokenId, // uint256 tokenIdCurrent;
            tokenContract, // address tokenContract;
            price, // uint256 price;
            paymentContract, // address paymentContract;
            _msgSender(), // address creator;
            payable(_msgSender()) // address feeReceiver;
        );
    }
    
    function sellFor(uint64 marketId, uint256 tokenId, address tokenContract, address paymentContract, uint price, address payable feeReceiver) external /**topUp*/ nonReentrant {
        IERC721(tokenContract).transferFrom(_msgSender(), address(this), tokenId);
        _makeSale(
            marketId,
            tokenId, // uint256 tokenIdCurrent;
            tokenContract, // address tokenContract;
            price, // uint256 price;
            paymentContract, // address paymentContract;
            _msgSender(), // address creator;
            feeReceiver // address feeReceiver;
        );
    }

    // Update sale price, TODO: emit event
    // function updateSalePayment(uint256 saleId, uint256 price, address paymentContract) external /**topUp*/ {
    //     TokenSale storage sale = _tokenSales[saleId];
    //     require(owner() == _msgSender() || sale.creator == _msgSender());
    //     sale.price = price;
    //     sale.paymentContract = paymentContract;
    // }

    // function updateSaleOwner(uint256 saleId, address payable saleOwner) external /**topUp*/ {
    //     TokenSale storage sale = _tokenSales[saleId];
    //     require(owner() == _msgSender() || sale.creator == _msgSender());
    //     sale.creator = saleOwner;
    // }

    function removeSale(uint256 saleId) onlyOwner() external /**topUp*/ nonReentrant {
        TokenSale storage sale = _tokenSales[saleId];
        require(!sale.finished);
        sale.finished = true;

        IERC721(sale.tokenContract).transferFrom(address(this), _msgSender(), sale.tokenId);

        emit SaleCancelled(sale.marketId, saleId, sale.tokenContract, sale.tokenId, sale.price, sale.paymentContract, sale.creator);
    }

    function onERC721Received(address operator, address /*from*/, uint256 tokenId, bytes calldata data) external override returns(bytes4) {
        if(data.length > 0){
            (uint256 price, address paymentContract, uint64 marketId, address feeReceiver) = abi.decode(data, (uint256, address, uint64, address));
            _makeSale(marketId, tokenId, _msgSender(), price, paymentContract, operator, payable(feeReceiver));
        }
        return(0x150b7a02);
    }

    function _makeSale(
        uint64 marketId, uint256 tokenId, 
        address tokenContract, uint256 price, address paymentContract, 
        address creator, address payable feeReceiver) marketExists(marketId) internal {
        // require(!_blacklist[_msgSender()]);
        TokenSale memory newSale = TokenSale(
            tokenId,
            tokenContract, // address tokenContract;
            price, // uint256 price;
            paymentContract, // address paymentContract;
            payable(creator), // address creator;
            feeReceiver, // address payable feeReceiver
            marketId, // uint64 marketId;
            false // bool finished
        );
        _tokenSales.push(newSale);
        emit SaleCreated(marketId, _tokenSales.length - 1, tokenContract, tokenId, price, paymentContract, creator);
    }
    
}
