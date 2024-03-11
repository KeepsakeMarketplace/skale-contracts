import { ethers } from "hardhat";
// const {BN, time} = require('@openzeppelin/test-helpers');

async function main() {

  /*
  let blockNumber =  await ethers.provider.getBlockNumber();
  let block = await ethers.provider.getBlock(blockNumber);
  
  const currentTimestampInSeconds = block?.timestamp;
  const unlockTime = currentTimestampInSeconds + 6000;
  */

  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 6000;

  const lockedAmount = ethers.parseEther("0.001");

  const lock = await ethers.deployContract("Lock", [unlockTime], {
    value: lockedAmount,
  });

  await lock.waitForDeployment();

  console.log(
    `Lock with ${ethers.formatEther(
      lockedAmount
    )}ETH and unlock timestamp ${unlockTime} deployed to ${lock.target}`
  );
  // await time.increase(6000);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
