pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTDocumentMinter is ERC721, ERC721Burnable, ERC721Pausable {
 
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(
        address owner,
        address mintedBy,
        string memory name,
        string memory symbol
    ) public ERC721(name, symbol) {}

    function mint(address user, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(user, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }   
}