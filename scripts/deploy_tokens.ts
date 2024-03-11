import { ethers } from "hardhat";
const fs = require('node:fs');
// import 'dotenv/config';
// const {BN, time} = require('@openzeppelin/test-helpers');

const dataFile = "./scripts/data.json";

async function main() {
  let network = process.env.HARDHAT_NETWORK || "";
  let test = network === "testnet";
  
  let gasLimit = test ? null : 100000000;

  let [signer] = await ethers.getSigners();
  let owner = signer.getAddress();

  const nft = await ethers.deployContract("ERC721", ["nft name", "A", owner], {gasLimit});
  await nft.waitForDeployment();

  console.log(
    `ERC721 deployed to ${nft.target}.`
  );
  const token = await ethers.deployContract("ERC20", [], {gasLimit});
  await token.waitForDeployment();
  await token.mint(owner, "1000000000000000000000000000000", {gasLimit});
  // await nft["mint(address,uint256)"](owner, "0", {gasLimit});

  console.log(
    `ERC20 deployed to ${token.target}.`
  );
  let deployment = JSON.parse(fs.readFileSync(dataFile));

  if(deployment[network].Market721) {
    let market = await ethers.getContractAt("Market721", deployment[network].Market721);
    await market.setContractOwnerInfo(nft.target, owner, 100, {gasLimit});
  }

  deployment[network].ERC721 = nft.target;
  deployment[network].ERC20 = token.target;
  fs.writeFileSync(dataFile, JSON.stringify(deployment));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
