pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC20Interface.sol";
import "./MinterRegistry.sol";
//import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";

contract NFTDocumentMinter is ERC721Pausable, MinterRegistry {
 
    using Counters for Counters.Counter;
    using SafeMath for uint;
    Counters.Counter private _tokenIds;
    address public owner;
    uint256 public protocolServiceFee;
    uint256 public mintingServiceFee;
    address public mintedBy;
    ERC20Interface public daiToken;
    address public protocolPaymentAddress;
    address public minterPaymentAddress;

    // DID: https://blog.ceramic.network/how-to-store-encrypted-secrets-using-idx/
    // MINTED: Must encrypt using DID, and then upload new document which will be tokenize
    // NFT Manager locks again to secure 
    // BURN_SWAP: Reads token uri from IPLD, and decrypts with DID
    // todo:  mapping de flow (REQUEST_MINTING, MINTED, BURN_SWAP)
    event BurnSwap(
        address minter,
        address from,
        uint id
    );

    /**
    * TODO
     */
    constructor(
        address _owner,
        address _mintedBy,
        string memory name,
        string memory symbol,
        /*uint serviceFee,
        uint protocolFee,
        address paymentAddress,
        address factoryPaymentAddress,*/
        ERC20Interface paymentToken
    ) public ERC721(name, symbol) {
        owner = _owner;
        mintedBy = _mintedBy;
        daiToken = paymentToken;
        /*mintingServiceFee = serviceFee;
        protocolServiceFee = protocolFee;
        minterPaymentAddress = paymentAddress;
        protocolPaymentAddress = factoryPaymentAddress;*/
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

        // TODO desplegar el fee de burn
        uint index = minterDocumentRequestCounter[address(this)];
        minterDocumentRequests[index].status = uint(DocumentMintingRequestStatus.MINTED);



        return newItemId;
    }   

    function burn(uint tokenId)
        public
        payable
        returns (bool)
    {

        // User must have a balance
        require(
            daiToken.balanceOf(msg.sender) >= 0,
            "Invalid token balance"
        );
        // User must have an allowance
        require(
            daiToken.allowance(msg.sender, address(this)) >= 0,
            "Invalid token allowance"
        );

        /* require(
            daiToken.balanceOf(msg.sender) == (mintingServiceFee.sum(protocolServiceFee)), 
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
            daiToken.transferFrom(
                msg.sender, 
                dataProvider.paymentAddress, 
                dataProvider.feeStructure),
            "Transfer failed for base token"
        );

        // Transfer tokens to pay service fee
        require(
            daiToken.transferFrom(
                msg.sender, 
                dataProvider.factoryAddress, 
                dataProvider.serviceFee),
            "Transfer failed for base token"
        );

        // TODO desplegar el fee de burn
        uint _index = minterDocumentRequestCounter[address(this)];
        minterDocumentRequests[_index].status = uint(DocumentMintingRequestStatus.BURNED);
        
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