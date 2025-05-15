// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PatientRecordVerification
 * @dev Simplified smart contract for patient record verification demo
 */
contract PatientRecordVerification {
    
    // Role-based access control
    enum Role { None, Patient, Doctor }
    
    // Structure for patient records
    struct PatientRecord {
        string recordHash;           // IPFS hash of the encrypted medical record
        uint256 timestamp;           // When the record was created
        address verifiedBy;          // Address of the doctor that verified it
        bool isVerified;             // Whether the record has been verified
    }
    
    // Structure for user accounts
    struct User {
        string name;                 // Name of the user
        Role role;                   // Role of the user
        bool isActive;               // Whether the user is active
    }
    
    // Mappings
    mapping(address => User) public users;
    mapping(address => mapping(bytes32 => PatientRecord)) private patientRecords;
    mapping(address => address[]) private authorizedViewers;
    
    // Events
    event UserRegistered(address indexed userAddress, string name, uint8 role);
    event RecordAdded(address indexed patient, bytes32 indexed recordId);
    event RecordVerified(address indexed patient, bytes32 indexed recordId, address verifier);
    event AccessGranted(address indexed patient, address indexed viewer);
    event AccessRevoked(address indexed patient, address indexed viewer);
    
    // Modifiers
    modifier onlyPatient() {
        require(users[msg.sender].role == Role.Patient, "Only patients can call this function");
        _;
    }
    
    modifier onlyDoctor() {
        require(users[msg.sender].role == Role.Doctor, "Only doctors can call this function");
        _;
    }
    
    /**
     * @dev Register a new user
     * @param _name Name of the user
     * @param _role Role of the user (1 = Patient, 2 = Doctor)
     */
    function registerUser(string memory _name, uint8 _role) public {
        require(users[msg.sender].role == Role.None, "User already registered");
        require(_role == 1 || _role == 2, "Invalid role");
        
        users[msg.sender] = User({
            name: _name,
            role: Role(_role),
            isActive: true
        });
        
        emit UserRegistered(msg.sender, _name, _role);
    }
    
    /**
     * @dev Add a new medical record
     * @param _recordId Unique ID for the record
     * @param _recordHash IPFS hash of the encrypted medical data
     */
    function addRecord(bytes32 _recordId, string memory _recordHash) public onlyPatient {
        require(bytes(patientRecords[msg.sender][_recordId].recordHash).length == 0, "Record already exists");
        
        patientRecords[msg.sender][_recordId] = PatientRecord({
            recordHash: _recordHash,
            timestamp: block.timestamp,
            verifiedBy: address(0),
            isVerified: false
        });
        
        emit RecordAdded(msg.sender, _recordId);
    }
    
    /**
     * @dev Verify a patient's medical record
     * @param _patient Address of the patient
     * @param _recordId ID of the record to verify
     */
    function verifyRecord(address _patient, bytes32 _recordId) public onlyDoctor {
        require(bytes(patientRecords[_patient][_recordId].recordHash).length > 0, "Record does not exist");
        
        // Check if the doctor is authorized to access the patient's records
        bool hasAccess = false;
        address[] memory viewers = authorizedViewers[_patient];
        for (uint i = 0; i < viewers.length; i++) {
            if (viewers[i] == msg.sender) {
                hasAccess = true;
                break;
            }
        }
        require(hasAccess, "Not authorized to verify this patient's records");
        
        PatientRecord storage record = patientRecords[_patient][_recordId];
        record.isVerified = true;
        record.verifiedBy = msg.sender;
        
        emit RecordVerified(_patient, _recordId, msg.sender);
    }
    
    /**
     * @dev Grant access to view medical records
     * @param _viewer Address of the doctor being granted access
     */
    function grantAccess(address _viewer) public onlyPatient {
        require(users[_viewer].role == Role.Doctor, "Access can only be granted to doctors");
        
        bool alreadyAuthorized = false;
        address[] storage viewers = authorizedViewers[msg.sender];
        
        for (uint i = 0; i < viewers.length; i++) {
            if (viewers[i] == _viewer) {
                alreadyAuthorized = true;
                break;
            }
        }
        
        if (!alreadyAuthorized) {
            authorizedViewers[msg.sender].push(_viewer);
            emit AccessGranted(msg.sender, _viewer);
        }
    }
    
    /**
     * @dev Revoke access to view medical records
     * @param _viewer Address of the doctor having access revoked
     */
    function revokeAccess(address _viewer) public onlyPatient {
        address[] storage viewers = authorizedViewers[msg.sender];
        for (uint i = 0; i < viewers.length; i++) {
            if (viewers[i] == _viewer) {
                // Replace the element to remove with the last element
                viewers[i] = viewers[viewers.length - 1];
                // Remove the last element
                viewers.pop();
                emit AccessRevoked(msg.sender, _viewer);
                break;
            }
        }
    }
    
    /**
     * @dev Get a patient's medical record
     * @param _patient Address of the patient
     * @param _recordId ID of the record to retrieve
     * @return Record hash, timestamp, verifier, and verification status
     */
    function getRecord(address _patient, bytes32 _recordId) public view 
        returns (string memory, uint256, address, bool) 
    {
        // Check if caller is patient or authorized viewer
        bool hasAccess = false;
        if (msg.sender == _patient) {
            hasAccess = true;
        } else {
            address[] memory viewers = authorizedViewers[_patient];
            for (uint i = 0; i < viewers.length; i++) {
                if (viewers[i] == msg.sender) {
                    hasAccess = true;
                    break;
                }
            }
        }
        
        require(hasAccess, "Not authorized to access this record");
        require(bytes(patientRecords[_patient][_recordId].recordHash).length > 0, "Record does not exist");
        
        PatientRecord memory record = patientRecords[_patient][_recordId];
        return (
            record.recordHash,
            record.timestamp,
            record.verifiedBy,
            record.isVerified
        );
    }
    
    /**
     * @dev Check if a record has been verified
     * @param _patient Address of the patient
     * @param _recordId ID of the record to check
     * @return Whether the record is verified
     */
    function isRecordVerified(address _patient, bytes32 _recordId) public view returns (bool) {
        return patientRecords[_patient][_recordId].isVerified;
    }
    
    /**
     * @dev Get the list of authorized viewers for a patient
     * @return Array of addresses authorized to view records
     */
    function getAuthorizedViewers() public view onlyPatient returns (address[] memory) {
        return authorizedViewers[msg.sender];
    }
    
    /**
     * @dev Check if a doctor is authorized to view a patient's records
     * @param _patient The patient address
     * @param _doctor The doctor address
     * @return Whether the doctor is authorized
     */
    function isAuthorized(address _patient, address _doctor) public view returns (bool) {
        address[] memory viewers = authorizedViewers[_patient];
        for (uint i = 0; i < viewers.length; i++) {
            if (viewers[i] == _doctor) {
                return true;
            }
        }
        return false;
    }
} 