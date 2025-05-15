# Patient Record Verification Demo

A blockchain application that demonstrates secure medical record storage and verification with access control.

## Features

- Patients can add medical records to the blockchain
- Patients control who can access and verify their records
- Doctors can verify patient records only if granted access
- All transactions are recorded on the blockchain for security and transparency

## Demo Workflow

This application is designed to demonstrate a specific workflow:

1. **Patient Registration and Record Creation**:
   - Connect with MetaMask (Patient account)
   - Register as a Patient
   - Add a medical record
   - Grant access to a Doctor's address

2. **Doctor Verification (Before Access)**:
   - Connect with MetaMask (Doctor account)
   - Register as a Doctor
   - Try to verify the Patient's record (should fail)

3. **Doctor Verification (After Access)**:
   - After the Patient grants access, try to verify again (should succeed)
   
4. **Revoking Access**:
   - Switch back to Patient
   - Verify that the record shows as "Verified"
   - Revoke access from the Doctor
   - Add another record and demonstrate that the Doctor can no longer verify it

## Setup Instructions

### Prerequisites

- Node.js and npm
- MetaMask extension in your browser
- Two different MetaMask accounts (one for Patient, one for Doctor)

### Installation

1. Clone the repository:
   ```
   git clone [repository-url]
   cd patient-record-blockchain
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Start a local blockchain:
   ```
   npx hardhat node
   ```

4. In a new terminal, deploy the smart contract:
   ```
   npx hardhat run scripts/deploy.js --network localhost
   ```
   Note the contract address from the output.

5. Update the contract address in the frontend:
   - Open `frontend/src/App.js`
   - Update the `CONTRACT_ADDRESS` variable with the deployed contract address

6. Start the frontend application:
   ```
   cd frontend
   npm install
   npm start
   ```

7. Open your browser to `http://localhost:3000`

8. Configure MetaMask:
   - Connect to the local network (localhost:8545)
   - Import some of the accounts from the Hardhat node (private keys are displayed when you start the node)

## Demo Step-by-Step

### Patient Side (First Browser Window)
1. Connect wallet with a patient account
2. Register as a Patient
3. Add a medical record (use any ID and hash for demo purposes)
4. Note your account address
5. Grant access to the doctor's account address

### Doctor Side (Second Browser Window)
1. Connect wallet with a doctor account
2. Register as a Doctor
3. Try to verify the patient's record by entering the patient's address and record ID (should fail with "Not authorized")
4. Once the patient grants access, try again (should succeed)

### Back to Patient Side
1. Refresh the records (click the "Refresh" button)
2. Verify that the record now shows as "Verified"
3. Revoke the doctor's access
4. Add another record
5. Confirm that the doctor can no longer verify the new record

## Important Notes

- This is a demonstration application and not intended for production use
- In a real application, the record data would be encrypted and stored on IPFS or a similar decentralized storage system
- The blockchain only stores references (hashes) to the medical data, not the data itself

## License

MIT 

## Troubleshooting Common Issues

### Network Connection Issues

If you encounter problems connecting to the blockchain:

1. **Check MetaMask Network**: Ensure you're connected to the correct network (Hardhat local network with Chain ID 31337)
2. **Contract Address**: Verify that the contract address in `frontend/src/App.js` matches your deployed contract
3. **Restart Hardhat Node**: If you've restarted your Hardhat node, you may need to reset your MetaMask account:
   - Go to Settings > Advanced > Reset Account in MetaMask
   - This clears transaction history without affecting your account

### User Role Access Issues

The application has role-based access control:

1. **Patient-Only Functions**: Some functions like `getAuthorizedViewers()` are restricted to patients only
2. **Access Denied Messages**: If you see "Access Denied" when viewing records, it means your account doesn't have permission
3. **Verification Errors**: Doctors can only verify records for patients who have explicitly granted them access

### Local Development Tips

1. **Hot Reloading**: Changes to the frontend code will automatically reload the application
2. **Contract Changes**: If you modify and redeploy the smart contract, you must update the contract address in the frontend
3. **MetaMask Account Switching**: The application can detect account changes in MetaMask and will update accordingly 