pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC20Interface.sol";
import "./MinterRegistry.sol";

contract NFTDocumentMinter is ERC721Pausable, MinterRegistry {
 
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
        string memory symbol,
        address tokenAddress
    ) public ERC721(name, symbol) {
        owner = msg.sender;
        stablecoin  = ERC20Interface(tokenAddress);
    }
   
    function mint(uint requestId, address user, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(user, newItemId);
        _setTokenURI(newItemId, tokenURI);

        // TODO desplegar el fee de burn
        if (requestId > 0) {
            minterDocumentRequests[address(this)][requestId].status = uint(DocumentMintingRequestStatus.MINTED);
        }

        return newItemId;
    }   

    function burn(uint requestId, uint tokenId)
        public
        payable
        returns (bool)
    {

        // User must have a balance
        require(
            stablecoin.balanceOf(msg.sender) >= 0,
            "Invalid token balance"
        );
        // User must have an allowance
        require(
            stablecoin.allowance(msg.sender, address(this)) >= 0,
            "Invalid token allowance"
        );

        /* require(
            stablecoin.balanceOf(msg.sender) == (mintingServiceFee.sum(protocolServiceFee)), 
            "MUST SEND FEE BEFORE USE");
        */

        uint index = minterCounter[address(this)];
        DataProviderMinter memory dataProvider = dataProviderMinters[index];
        
        _burn(tokenId);

        // TODO: Update accounting
        //  - create mappings to data provider accounting
        //  - create mappings to protocol fee accounting

        // Transfer tokens to NFT owner
        require(
            stablecoin.transferFrom(
                msg.sender, 
                dataProvider.paymentAddress, 
                dataProvider.feeStructure),
            "Transfer failed for base token"
        );

        // Transfer tokens to pay service fee
        require(
            stablecoin.transferFrom(
                msg.sender, 
                dataProvider.factoryAddress, 
                dataProvider.serviceFee),
            "Transfer failed for base token"
        );

        // TODO desplegar el fee de burn
        if (requestId > 0) {
            minterDocumentRequests[address(this)][requestId].status = uint(DocumentMintingRequestStatus.BURNED);
        }
        emit BurnSwap(
            address(this),
            msg.sender,
            tokenId
        );

        return true;
    }       

      function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal virtual override
    {
        super._beforeTokenTransfer(from, to, amount);

//        require(_validRecipient(to), "ERC20WithSafeTransfer: invalid recipient");
    }

}