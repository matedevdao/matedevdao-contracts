import { config } from "chai";
import { ethers, network } from "hardhat";
import { MetamaskClient } from "hardhat_metamask_client";

const MATE_ONCHAIN_IMAGES_CONTRACT_ADDRESS =
  "0x059308948cf1F550E15869f9C3E02dCEb8814F0A";

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

  const impl = await MateOnchainImages.deploy(
    MATE_ONCHAIN_IMAGES_CONTRACT_ADDRESS,
  );
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
