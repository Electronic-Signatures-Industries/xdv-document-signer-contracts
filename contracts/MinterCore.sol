pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 *  @dev MinterCore
 */
contract MinterCore {
    // Documents provider mappings
    mapping(address => uint) public minterCounter;
    mapping(uint => DataProviderMinter) public dataProviderMinters;

    // Requested Documents by minter id sequence/autonumber
    mapping(address => uint) public minterDocumentRequestCounter;

    // Requests by minter by autonumber
    mapping(address => mapping(uint => DocumentMintingRequest)) public minterDocumentRequests;
    
    enum DocumentMintingRequestStatus   {
        REQUEST,
        MINTED,
        BURNED
    }

    // Document minting request
    struct DocumentMintingRequest {
        address user;
        string userDid;
        address toMinter; // NFT
        string toMinterDid;
        string documentURI;
        uint status;    
        uint timestamp;    
        string description;
    }

    // Document minting provider
    struct DataProviderMinter {
        address minterAddress;
        string name;
        address paymentAddress;//*
        bool hasUserKyc;
        uint feeStructure;//*
        uint created;
        uint serviceFee;//*
        address factoryAddress;//*
        bool enabled;
    }

    // RequestMinting events
    event MinterRegistered(
        address indexed minter, // NFT
        uint indexed id,
        string name
    );

    // DocumentAnchored events
    event DocumentAnchored(
        address indexed user, 
        string indexed userDid,
        string documentURI,
        uint id
    );

  
}

