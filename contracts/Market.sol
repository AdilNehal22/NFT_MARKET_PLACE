//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarket is ReentrancyGuard {
    
    using Counters for Counters.Counter;
    Counters.Counter private itemIds;
    Counters.Counter private itemSold;

    address payable owner;

    uint256 listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    //to return listing price of contract
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    //item on sale in the market
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be atleast 1 Wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        itemIds.increment();
        uint256 itemId = itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)), //item created but not sold so, address 0
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    //sale the item and transfer funds to seller
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {

        uint256 price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;
        require(msg.value == price, "Submit the price that is asked inorder to procees purchase");

        idToMarketItem[itemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        itemSold.increment();
        payable(owner).transfer(listingPrice);

    }

    function fetchMarketItems() public view returns (MarketItem[] memory){

        uint itemCount = itemIds.current();
        uint unsoldItemCount = itemIds.current() - itemSold.current();
        //we want to keep the local value to increment the number, we will be looping
        //over number of items created, and we will increment that number if we have an
        //empty address, if the item has an empty address that means its not yet been sold
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for(uint i=0; i < itemCount; i++){
            //if the address of owner is empty address that means it is not sold
            if(idToMarketItem[i+1].owner == address(0)){
                //item id we are interacting with
                uint currentId = i+1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    //return item users created
    function fetchItemsCreated() public view returns (MarketItem[] memory){

        uint totalItemCount = itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for(uint i=0; i < totalItemCount; i++){
            if(idToMarketItem[i + 1].seller == msg.sender){
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for(uint i=0; i < totalItemCount; i++){
            if(idToMarketItem[i+1].seller == msg.sender){
                uint currentId = i+1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    //fetching the NFTS that I have purchased
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
            itemCount += 1;
        }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
            uint currentId = i + 1;
            MarketItem storage currentItem = idToMarketItem[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }
    }
    return items;
  }


}
