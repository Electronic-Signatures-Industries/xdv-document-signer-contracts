pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DocumentManager {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address owner;
    address mintedBy;

    // DID: https://blog.ceramic.network/how-to-store-encrypted-secrets-using-idx/
    // MINTED: Must encrypt using DID, and then upload new document which will be tokenize
    // BURN_SWAP: Reads token uri from IPLD, and decrypts with DID
    // todo:  mapping de flow (REQUEST_MINTING, MINTED, BURN_SWAP)

    constructor(
        address _owner
    ) public {
        this.owner = _owner;
    }

    function burnSwap(
        address minter,
        uint id
    ) public returns (uint256) {
        require(NFTDocumentMinter(minter).mintedBy != address(0) , "NO CONTRACT MINTER FOUND");
        ERC721Burnable nft = NFTDocumentMinter(minter).get(id);
        require(
            nft.burn(),
            "Cannot burn token"
        );

        // todo: API listening

        // todo: emit event
        
        emit LogBurnSwap(
            minter,
            msg.sender,
            tokenURI
        );
        return newItemId;
    }
}
