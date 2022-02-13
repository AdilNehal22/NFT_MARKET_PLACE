const { expect } = require("chai");
const { ethers } = require("hardhat");

let Market;
let market;
let marketAddress;
let NFT;
let nft;
let nftContractAddress;

// let listingPrice
// let auctionPrice;
// let buyerAddress;


describe("NFTMarket", function() {

    it("Should create and execute market sales", async function() {
      Market = await ethers.getContractFactory("NFTMarket")
      market = await Market.deploy()
      await market.deployed()
      marketAddress = market.address
      console.log(` market deployed at: ${marketAddress}`);
    });

    it("deploys the NFT contracts", async function(){
      NFT = await ethers.getContractFactory("NFT")
      nft = await NFT.deploy(marketAddress)
      await nft.deployed()
      nftContractAddress = nft.address
      console.log(` NFT deployed at: ${nftContractAddress}`);
    });

    it("put item on market and sale and return unsolds", async function() {

      let listingPrice = await market.getListingPrice()
      listingPrice = listingPrice.toString()
  
      const auctionPrice = ethers.utils.parseUnits('1', 'ether')
  
     
      await nft.createToken("https://www.mytokenlocation.com")
      await nft.createToken("https://www.mytokenlocation2.com")
  
  
      await market.createMarketItem(nftContractAddress, 1, auctionPrice, { value: listingPrice })
      await market.createMarketItem(nftContractAddress, 2, auctionPrice, { value: listingPrice })
  
      const [_, buyerAddress] = await ethers.getSigners();
  
      await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, { value: auctionPrice})
  
      //return the unsold items 
      items = await market.fetchMarketItems()
      items = await Promise.all(items.map(async i => {
        const tokenUri = await nft.tokenURI(i.tokenId)
        let item = {
          price: i.price.toString(),
          tokenId: i.tokenId.toString(),
          seller: i.seller,
          owner: i.owner,
          tokenUri
        }
        return item
    }));
        console.log('items: ', items)
    });
});

// beforeEach(async () => {
//     Market = await ethers.getContractFactory("NFTMarket");
//     market = await Market.deploy();
//     await market.deployed();
//     marketAddress = market.address;
// })

// describe("Market Place", async()=> {

//     it("it deploys the market contract successfully", async () => {
//         console.log(`Market contract deployed at: ${marketAddress}`);
//     });

//     it("deploys the NFT contract", async () => {
//         NFT = await ethers.getContractFactory("NFT");
//         nft = await NFT.deploy(marketAddress);
//         await nft.deployed();
//         nftContractAddress = nft.address;
//         console.log(`NFT contract deployed at: ${nftContractAddress}`);
//     });

//     it("creates market item, put it on sale and give back unsold items.", async()=>{

//         listingPrice = await market.getListingPrice();
//         listingPrice = listingPrice.toString();

//         auctionPrice = ethers.utils.parseUnits('1', 'ether');

//         nft.createToken("https://www.mytokenlocation.com");
//         nft.createToken("https://www.mytokenlocation2.com");

//         create marketItem
//         value passing for this transaction being paid to contract owner
//         market.createMarketItem(nftContractAddress, 1, auctionPrice, { value: listingPrice });
//         market.createMarketItem(nftContractAddress, 2, auctionPrice, { value: listingPrice });

//         [_, buyerAddress] = await ethers.getSigners();

//         await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, { value: auctionPrice });

//         const items = await market.fetchMarketItems();
//         items = await Promise.all(items.map(async i => {
//             const tokenURI = await nft.tokenURI(i.tokenId);
//             let item = {
//                 price: i.price.toString(),
//                 tokenId: i.tokenId.toString(),
//                 seller: i.seller,
//                 owner: i.owner,
//                 tokenURI
//             }
//             return item;
//         }));
//         console.log('items: ', items);
//     });
   
// });

 