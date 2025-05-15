// scripts/deploy-local.js
const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying PatientRecordVerification contract to local network...");

  // Get the ContractFactory
  const PatientRecordVerification = await ethers.getContractFactory("PatientRecordVerification");
  
  // Deploy the contract
  const patientRecord = await PatientRecordVerification.deploy();

  // Wait for deployment to finish
await patientRecord.waitForDeployment(); // ✅ Correct method in Ethers v6

  console.log("PatientRecordVerification deployed locally to:", patientRecord.address);
  console.log(await patientRecord.getAddress()); // ✅ correct in v6

  console.log("Use this address in your frontend configuration");
}

// Execute the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error during deployment:", error);
    process.exit(1);
  });