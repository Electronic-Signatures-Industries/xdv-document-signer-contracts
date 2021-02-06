pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 *  Register Minters  debe ir un mapping, un evento de add registry, un counter para 
 saber cuantos registros , get de fetch que debe recibir un address, y returnar un struct de vuelta
 */
contract XDVDocumentAnchoring {
    // Document by minter id sequence/autonumber
    mapping(address => uint) public minterDocumentAnchorCounter;

    // Document by user address by id
    mapping(address => mapping(uint => DocumentAnchor)) public minterDocumentAnchors;

    // Document Anchor
    struct DocumentAnchor {
        address user;
        string userDid;
        string documentURI; 
        string description;
        uint timestamp;
    }

    // DocumentAnchored events
    event DocumentAnchored(
        address indexed user, 
        string indexed userDid,
        string documentURI,
        uint id
    );

    function addDocument(
        string memory userDid,
        string memory documentURI,
        string memory description
    ) public returns(uint){

        minterDocumentAnchorCounter[msg.sender]++;
        uint i = minterDocumentAnchorCounter[msg.sender];
            
        minterDocumentAnchors[msg.sender][i] = DocumentAnchor({
            user: msg.sender, 
            userDid: userDid,
            documentURI: documentURI,
            description: description,
            timestamp: block.timestamp
        });

        emit DocumentAnchored(msg.sender, userDid, documentURI, i);
        return i;
    }

}