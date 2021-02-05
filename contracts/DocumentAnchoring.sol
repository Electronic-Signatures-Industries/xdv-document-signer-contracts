pragma solidity ^0.7.0;
import "./NFTDocumentMinter.sol";
import "./MinterRegistry.sol";

/**
 *  Anchors IPLD cids by minter address
 */
contract DocumentAnchoring is MinterRegistry {
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
        string memory tokenURI,
        string memory description
    ) public returns (bool) {
        // Allow self minting
        if (selfMint == true) {
            // Is sender owner of minter
            uint id = NFTDocumentMinter(minter).mint(0, msg.sender, tokenURI);
            
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
        
        minterDocumentRequests[minter][i] = DocumentMintingRequest({
            user: msg.sender, 
            toMinterDid: minterDid,
            toMinter: minter,
            userDid: userDid, 
            documentURI: tokenURI,
            status: uint(DocumentMintingRequestStatus.REQUEST),
            description: description
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
