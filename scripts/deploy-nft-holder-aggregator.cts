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

  console.log("Deploying NFTHolderAggregator to ", network.name);

  const NFTHolderAggregator = await ethers.getContractFactory(
    "NFTHolderAggregator",
    signer,
  );

  const impl = await NFTHolderAggregator.deploy();
  await impl.waitForDeployment();
  console.log("NFTHolderAggregator deployed to:", impl.target);

  client.close();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
