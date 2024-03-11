
import { task } from "hardhat/config";
const fs = require('node:fs');
const dataFile = "./scripts/data.json";
var argv = require('minimist')(process.argv.slice(2));
// import 'dotenv/config';

task("mint", "Mints an NFT")
  .addPositionalParam("to", "the owner address")
  .addPositionalParam("amount", "the number of nfts to mint")
  .setAction(async (taskArgs) => {

  let network = argv.network || "";

  let test = network === "testnet";
  let gasLimit = test ? null : 30000000;

  let [signer] = await ethers.getSigners();
  let owner = await signer.getAddress();
    
  let deployment = JSON.parse(fs.readFileSync(dataFile));

  if(!deployment[network].data){
    deployment[network].data = {nft_id: 0};
  }

  let nft = await ethers.getContractAt("ERC721", deployment[network].ERC721);
  let i = 0;
  while (i < taskArgs.amount) {
    let res = await nft["mint(address,uint256)"](taskArgs.to, deployment[network].data.nft_id, {gasLimit});
    deployment[network].data.nft_id+=1;
    i++;
    console.log(res.hash);
  }

  fs.writeFileSync(dataFile, JSON.stringify(deployment));

  // let market = await ethers.getContractAt("Market721", deployment[network].Market721);
  // await market.setMarket("0", "100", owner, {gasLimit});
  // const token = await ethers.getContractAt("ERC20", deployment[network].ERC20);
  // await token.mint(owner, "1000000000000000000000000", {gasLimit});
  

});

task("print", "Mints ERC20 tokens")
  .addPositionalParam("to", "the owner address")
  .addPositionalParam("amount", "the amount of tokens to mint")
  .setAction(async (taskArgs) => {

  let network = argv.network || "";

  let test = network === "testnet";
  let gasLimit = test ? null : 30000000;

    
  let deployment = JSON.parse(fs.readFileSync(dataFile));
  const token = await ethers.getContractAt("ERC20", deployment[network].ERC20);
  let res = await token.mint(taskArgs.to, `${taskArgs.amount}000000000000000000`, {gasLimit});
  console.log(res.hash);
});



task("collection", "Mints an ERC721 contract + tokens")
.addPositionalParam("to", "the owner address")
.addPositionalParam("amount", "the number of nfts to mint")
.setAction(async (taskArgs) => {
  let network = argv.network || "";
  let test = network === "testnet";
  
  let gasLimit = test ? null : 100000000;

  let [signer] = await ethers.getSigners();
  let owner = signer.getAddress();

  const nft = await ethers.deployContract("ERC721", ["nft name", "A", owner], {gasLimit});
  await nft.waitForDeployment();
  await nft.setBaseURI("https://ipfs.io/ipfs/QmRxKzm1exEDjhjE6XsYaBL8WE2kENBCraw4MAiACZn7PJ", {gasLimit});

  let deployment = JSON.parse(fs.readFileSync(dataFile));

  if(deployment[network].Market721) {
    let market = await ethers.getContractAt("Market721", deployment[network].Market721);
    await market.setContractOwnerInfo(nft.target, owner, 100, {gasLimit});
  }

  let i = 0;
  while (i < taskArgs.amount) {
    let res = await nft["mint(address,uint256)"](taskArgs.to, i, {gasLimit});
    i++;
    console.log(res.hash);
  }


});
