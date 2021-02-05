pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 *  Register Minters  debe ir un mapping, un evento de add registry, un counter para 
 saber cuantos registros , get de fetch que debe recibir un address, y returnar un struct de vuelta
 */
contract MinterRegistry {
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
        string description;
    }

    // Document minting provider
    struct DataProviderMinter {
        address minterAddress;
        string name;
        string symbol;
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
        string name,
        string indexed symbol
    );

    constructor() public {

    }
    
    function addToRegistry(
        address minter,
        string memory name,
        string memory symbol,
        address paymentAddress,
        bool hasUserKyc,
        uint feeStructure,
        uint serviceFee,
        address factoryAddress  
    ) public returns(uint){

        minterCounter[minter]++;
        uint i = minterCounter[minter];
            
        dataProviderMinters[i] = DataProviderMinter({
            minterAddress: minter, 
            name: name,
            symbol: symbol,
            paymentAddress: paymentAddress,
            hasUserKyc: hasUserKyc,
            feeStructure: feeStructure,
            created: block.timestamp,
            serviceFee: serviceFee,
            factoryAddress: factoryAddress,
            enabled: true
        });

        emit MinterRegistered(minter, i, name, symbol);
        return i;
    }

}

