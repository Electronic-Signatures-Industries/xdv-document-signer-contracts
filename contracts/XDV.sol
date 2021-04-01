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
    uint public serviceFee;

    mapping(address => uint) public serviceAccounting;


    /**
     * XDV Data Token
     */
    constructor(string memory name, string memory symbol, address tokenERC20)
        public
        ERC721(name, symbol)
    {
        owner = msg.sender;
        stablecoin = ERC20Interface(tokenERC20);
    }

    function setProtocolFee(uint256 _fee) public {
        require(msg.sender == owner, "INVALID_USER");
        serviceFee = _fee;
    }

    function getProtocolFee() public returns (uint256) {
        return serviceFee;
    }


    /**
     * @dev Mints a XDV Data Token if whitelisted
     */
    function mint(address user, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(user, newItemId);
        _setTokenURI(newItemId, tokenURI);


        return newItemId;
    }
    /**
    *  @dev Burns a platform token.
     */
    function burn(
        address caller,
        uint tokenId,
        uint providerFee,
        address paymentAddress
    )
        public
        payable
        returns (bool)
    {

        // User must have a balance
        require(
            stablecoin.balanceOf(caller) >= 0,
            "Invalid token balance"
        );
        // User must have an allowance
        require(
            stablecoin.allowance(caller, address(this)) >= 0,
            "Invalid token allowance"
        );
        require(
            providerFee > 0,
            "Must have set a fee structure"
        );
        require(
            paymentAddress != address(0),
            "Must have a payment address"
        );
        require(
            serviceFee > 0,
            "Must have set a service fee"
        );
        
        _burn(tokenId);

        // Transfer tokens to NFT owner, change pull pattern
        require(
            stablecoin.transferFrom(
                caller, 
                paymentAddress, 
                providerFee),
            "Transfer failed for base stablecoin"
        );

        // Transfer tokens to pay service fee
        require(
            stablecoin.transferFrom(
                caller, 
                address(this), 
                serviceFee),
            "Transfer failed for base token"
        );

        serviceAccounting[address(this)] += serviceFee;
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
