pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC20Interface.sol";

contract XDV is ERC721Pausable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private _tokenIds;
    address public owner;
    ERC20Interface public stablecoin;
    mapping(address => bool) public whitelistedMinters;
    address public platformOwner;

    /**
     * XDV Data Token
     */
    constructor(string memory name, string memory symbol)
        public
        ERC721(name, symbol)
    {
        owner = msg.sender;
    }

    function setPlatformOwner(address user)
        public
        returns (bool)
    {
        require(msg.sender == owner);

        platformOwner = user;

        return true;
    }
    function setWhitelistedMinter(address user)
        public
        returns (bool)
    {
        require(msg.sender == owner);
        whitelistedMinters[user] = true;

        return true;
    }

    /**
     * @dev Mints a XDV Data Token if whitelisted
     */
    function mint(address user, string memory tokenURI)
        public
        returns (uint256)
    {
        require(
            whitelistedMinters[msg.sender],
            "User has not been whitelisted"
        );
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(user, newItemId);
        _setTokenURI(newItemId, tokenURI);

        // minted, remove user
        if (msg.sender != platformOwner) {
            // whitelistedMinters[msg.sender] = false;
        }

        return newItemId;
    }

    function burn(uint256 tokenId) public returns (bool) {
        require(
            msg.sender == platformOwner,
            "Burn only allowed via platform owner"
        );

        _burn(tokenId);
        return true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        //        require(_validRecipient(to), "ERC20WithSafeTransfer: invalid recipient");
    }
}
