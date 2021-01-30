pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./NFTDocumentMinter.sol";

/**
 *  Anchors IPLD cids by minter address
 */
contract DocumentAnchoring {
    // Documents by minter counters
    mapping(address => uint) public minterDocumentRequestCounter;

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
    }

    // Document minter items
    DocumentMintingRequest[] public minterDocumentRequests;

    // RequestMinting events
    event RequestMinting(
        address minter, // NFT
        address from,
        string tokenURI,
        uint anchorId
    );


    // SelfMinted event
    event SelfMinted(
        address minter, // NFT
        address from,
        string tokenURI,
        uint tokenId
    );    
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    /** NatDoc
     * @dev Requests minting service  from a document minting provider or self mintingss
     * minter
     * selfMint
     * tokenURI
     */
    function requestMint(
        address minter,
        string memory minterDid,
        string memory userDid,
        bool selfMint,
        string memory tokenURI
    ) public returns (bool) {
        // Checks if there is a valid address
        require(NFTDocumentMinter(minter).mintedBy() != address(0) , "NO CONTRACT MINTER FOUND");
 
        // Allow self minting
        if (selfMint == true) {
            // Is sender owner of minter
            require(NFTDocumentMinter(minter).mintedBy() == msg.sender, "INVALID MINTER ACCESS");
            uint id = NFTDocumentMinter(minter).mint(msg.sender, tokenURI);
            
            emit SelfMinted(
                minter, 
                msg.sender, 
                tokenURI, 
                id
            );
            return true;
        }

        // otherwise add request for minting to minter
        minterDocumentRequestCounter[minter]++;
        uint i = minterDocumentRequestCounter[minter];
        
        minterDocumentRequests[i] = DocumentMintingRequest({
            user: msg.sender, 
            toMinterDid: minterDid,
            toMinter: minter,
            userDid: userDid, 
            documentURI: tokenURI,
            status: uint(DocumentMintingRequestStatus.REQUEST)
        });
        emit RequestMinting(
            minter,
            msg.sender,
            tokenURI,
            i
        );
        return true;
    }
}
