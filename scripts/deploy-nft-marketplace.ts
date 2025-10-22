import { config } from "chai";
import { ethers, network } from "hardhat";
import { MetamaskClient } from "hardhat_metamask_client";

async function main() {
  const client = new MetamaskClient({
    hardhatConfig: config,
    networkName: network.name,
    network,
    ethers,
  });
  const signer = await client.getSigner();

  console.log("Deploying NFTMarketplace to ", network.name);

  const NFTMarketplace = await ethers.getContractFactory(
    "NFTMarketplace",
    signer,
  );

  const impl = await NFTMarketplace.deploy();
  await impl.waitForDeployment();
  console.log("NFTMarketplace deployed to:", impl.target);

  client.close();
  process.exit();
}

main();
