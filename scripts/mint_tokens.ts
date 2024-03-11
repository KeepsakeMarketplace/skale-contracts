
import { ethers } from "hardhat";
var argv = require('minimist')(process.argv.slice(2));
// import 'dotenv/config';
// const {BN, time} = require('@openzeppelin/test-helpers');

async function main() {
  let network = process.env.HARDHAT_NETWORK || "";
  let test = network === "testnet";
  let gasLimit = test ? null : 100000000;

  let [signer] = await ethers.getSigners();
  let owner = signer.getAddress();
  // let data = await signer.estimateGas({ data: contract.bytecode });
  // console.log(data);

  const nft = await ethers.getContractAt("ERC721", "0x5E3A24B02D0cD009E83C28b9cE751782F4Dbc10a");

  //const token = await ethers.getContractAt("ERC20", "0x9Dccf37C948C9D48a99CBFCd35BA861Ad152028f");
  
  //await token.mint(owner, "1000000000000000000000000", {gasLimit});
  // await nft["mint(address,uint256)"](owner, "3", {gasLimit});

  // const market = await ethers.getContractAt("Market721", "0x436C2dB865605fE7EcaD5c93C8512BD214b465A1");
  // await market.setContractOwnerInfo(nft.target, owner, 100, {gasLimit});
  // await market.setMarket("0", "100", owner, {gasLimit});
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
