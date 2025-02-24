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

  console.log("Deploying MateOnchainImages to ", network.name);

  const MateOnchainImages = await ethers.getContractFactory(
    "MateOnchainImages",
    signer,
  );

  const impl = await MateOnchainImages.deploy();
  await impl.waitForDeployment();
  console.log("MateOnchainImages deployed to:", impl.target);

  client.close();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
