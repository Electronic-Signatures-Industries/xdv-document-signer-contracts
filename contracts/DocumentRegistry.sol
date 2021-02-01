pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./NFTDocumentMinter.sol";

contract DocumentRegistry {
    using Counters for Counters.Counter;
    mapping(address => Counters.Counter) public minterDocumentRequestCounter;
    struct DocumentMintingRequest {
        address from;
        address toMinter;
        string documentURI;  
        uint status;      
    }
    DocumentMintingRequest[] public minterDocumentRequests;
    event LogRequestMinting(
        address minter,
        address from,
        string tokenURI,
        uint requestId
    );
    address owner;

    constructor(
        address _owner
    ) public {
        owner = _owner;
    }

    function requestMint(
        address minter,
        bool selfMint,
        string memory tokenURI
    ) public returns (bool) {
        require(NFTDocumentMinter(minter).mintedBy() != address(0) , "NO CONTRACT MINTER FOUND");
        if (selfMint == true) {
            require(NFTDocumentMinter(minter).mintedBy() == msg.sender, "INVALID MINTER ACCESS");
            NFTDocumentMinter(minter).mint(msg.sender, tokenURI);
            // todo: emit event
            return true;
        }
        minterDocumentRequestCounter[minter].increment();
        uint i = minterDocumentRequestCounter[minter].current();
        
        minterDocumentRequests[i] = (DocumentMintingRequest(msg.sender, minter, tokenURI));
        emit LogRequestMinting(
            minter,
            msg.sender,
            tokenURI,
            minterDocumentRequestCounter[minter].current()
        );
        return true;
    }
}
