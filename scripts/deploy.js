// We require the Hardhat Runtime Environment explicitly here
const hre = require("hardhat");

async function main() {
  console.log("Deploying PatientRecordVerification contract...");
  
  // Get the contract factory
  const PatientRecordVerification = await hre.ethers.getContractFactory("PatientRecordVerification");
  
  // Deploy contract
  console.log("Sending deployment transaction...");
  const contract = await PatientRecordVerification.deploy();
  console.log("Waiting for deployment...");
  
  // Different versions of ethers handle deployment differently
  try {
    // Try ethers v6 approach
    await contract.waitForDeployment();
  } catch (error) {
    try {
      // Fall back to ethers v5 approach
      await contract.deployed();
    } catch (innerError) {
      try {
        // Last resort: just wait for transaction
        await contract.deployTransaction.wait();
      } catch (finalError) {
        console.error("Could not confirm deployment:", finalError);
      }
    }
  }
  
  // Get address (compatible with different versions)
  const address = contract.address || (typeof contract.getAddress === 'function' ? await contract.getAddress() : null);
  
  console.log(`PatientRecordVerification deployed to: ${address}`);
  console.log("Deployment complete!");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 