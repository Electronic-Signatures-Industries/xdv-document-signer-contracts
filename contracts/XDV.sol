pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC20Interface.sol";

contract XDV is ERC721Pausable {
 
    using Counters for Counters.Counter;
    using SafeMath for uint;
    Counters.Counter private _tokenIds;
    address public owner;
    ERC20Interface public stablecoin;

    event BurnSwap(
        address minter,
        address from,
        uint id
    );

    /**
    * XDV Data Token
    */
    constructor(
        string memory name,
        string memory symbol
    ) public ERC721(name, symbol) {
        owner = msg.sender;
    }
   
    function mint(address user, string memory tokenURI)
        public
        returns (uint256)
    {
        require(msg.sender == owner);
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(user, newItemId);
        _setTokenURI(newItemId, tokenURI);
  
        return newItemId;
    }   

    function burn(uint tokenId)
        public
        returns (bool)
    {
        require(msg.sender == owner);
        
        _burn(tokenId);
        return true;
    }       

      function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal virtual override
    {
        super._beforeTokenTransfer(from, to, amount);

//        require(_validRecipient(to), "ERC20WithSafeTransfer: invalid recipient");
    }

}