// Simple Hardhat deployment script - create a new file that should work regardless of Hardhat version
const hre = require("hardhat");

async function main() {
  console.log("Deploying contract...");
  
  // Get the contract factory
  const Factory = await hre.ethers.getContractFactory("PatientRecordVerification");
  
  // Deploy
  console.log("Deploying...");
  const contract = await Factory.deploy();
  console.log(`Contract deployed to transaction: ${contract.deployTransaction.hash}`);
  
  console.log("Waiting for confirmation...");
  // Wait for confirmation - this should work on any version
  const receipt = await contract.deployTransaction.wait();
  
  console.log(`Contract deployed to: ${contract.address}`);
  console.log(`Deployment confirmed in block: ${receipt.blockNumber}`);
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.error(e);
    process.exit(1);
  }); 