pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DocumentRegistry {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address owner;
    address mintedBy;

    constructor(
        address _owner
    ) public {
        this.owner = _owner;
    }

    function requestMint(
        address minter,
        bool selfMint,
        string memory tokenURI
    ) public returns (uint256) {
        require(NFTDocumentMinter(minter).mintedBy != address(0) , "NO CONTRACT MINTER FOUND");
        if (selfMint == true) {
            require(NFTDocumentMinter(minter).mintedBy == msg.sender, "INVALID MINTER ACCESS");
            NFTDocumentMinter(minter).mint(msg.sender, tokenURI);

            // todo: emit event
        }
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(user, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}
