pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTDocumentMinter is ERC721Pausable {
 
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address public owner;
    uint256 public fee = 0.002 * 1e18;
    address public mintedBy;
    
    // DID: https://blog.ceramic.network/how-to-store-encrypted-secrets-using-idx/
    // MINTED: Must encrypt using DID, and then upload new document which will be tokenize
    // NFT Manager locks again to secure 
    // BURN_SWAP: Reads token uri from IPLD, and decrypts with DID
    // todo:  mapping de flow (REQUEST_MINTING, MINTED, BURN_SWAP)
    event LogBurnSwap(
        address minter,
        address from,
        uint id
    );

    constructor(
        address _owner,
        address _mintedBy,
        string memory name,
        string memory symbol,
        uint burnFee
    ) public ERC721(name, symbol) {
        owner = _owner;
        mintedBy = _mintedBy;
        fee = burnFee;
    }
   
    function mint(address user, string memory tokenURI)
        public
        returns (uint256)
    {
        require(mintedBy == msg.sender, "INVALID MINTER");
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(user, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }   

    function burn(uint tokenId)
        public
        payable
        returns (bool)
    {
        require(msg.value == fee, "MUST SEND FEE BEFORE USE");
        // todo: validate using DAI stablecoin

        _burn(tokenId);

        // todo: API listening
        // 1. Unlock (master decrypt)
        // 2. IPLD (Alice DID pub)

        // todo: emit event
        
        emit LogBurnSwap(
            address(this),
            msg.sender,
            tokenId
        );


        // todo: transferFrom to mintedBy
        // todo: transferFrom to owner (tx fee)
        // todo: emit event
        return true;
    }       

      function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal virtual override
    {
        super._beforeTokenTransfer(from, to, amount);

//        require(_validRecipient(to), "ERC20WithSafeTransfer: invalid recipient");
    }

}