import { ethers } from "hardhat";
const fs = require('node:fs');
// const {BN, time} = require('@openzeppelin/test-helpers');
// await time.increase(6000);

const dataFile = "./scripts/data.json";

async function main() {
  let network = process.env.HARDHAT_NETWORK || "";
  let test = network === "testnet";

  let [signer] = await ethers.getSigners();
  let gasLimit = test ? null : 100000000;
  let owner = signer.getAddress();

  let market = await ethers.deployContract("Market721", [], {gasLimit});
  await market.waitForDeployment();

  let marketAddress = await market.target;
  const proxy = await ethers.deployContract("MarketProxy", [marketAddress], {gasLimit});
  await proxy.waitForDeployment();
  market = market.attach(proxy.target);
  await market.setMarket("0", "100", owner, {gasLimit});

  console.log(
    `Proxy for Market721 deployed to ${proxy.target}, with logic contract at ${marketAddress}.`
  );

  let deployment = JSON.parse(fs.readFileSync(dataFile));

  if(deployment[network].ERC721) {
    let nft = await ethers.getContractAt("ERC721", deployment[network].ERC721);
    await market.setContractOwnerInfo(nft.target, owner, 100, {gasLimit});
  }

  deployment[network].Market721 = proxy.target;
  fs.writeFileSync(dataFile, JSON.stringify(deployment));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
