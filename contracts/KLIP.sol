// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./KlipCore.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//TODO: Must change transferfrom to claim pattern to avoid frontrunning

contract KLIP is
    KlipCore,
    ERC721Burnable,
    ERC721Pausable,
    ERC721Enumerable
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    IERC20 public stablecoin;
    uint256 public royalty = 0;
    uint256 public fee = 0;
    address public paymentAddress;
    mapping(uint256 => string) public fileUri;

    event Withdrawn(address indexed paymentAddress, uint256 amount);

    event ServiceFeePaid(
        uint256 indexed tokenId,
        address indexed from,
        address indexed paymentAddress,
        uint256 paidToContract,
        uint256 paidToPaymentAddress
    );

    /**
     * XDV Data Token
     */
    constructor(address tokenERC20, address newPaymentAddress)
        ERC721("KLIP Token", "KLIP")
    {
        paymentAddress = newPaymentAddress;
        stablecoin = IERC20(tokenERC20);
    }

    function setServiceRoyalty(uint256 _fee) public onlyOwner {
        royalty = _fee;
    }

    function setServiceFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function setPaymentAddress(address newAddress) public onlyOwner {
        paymentAddress = newAddress;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Mints a XDV Data Token if whitelisted
     * @return tokenIds
     */

    //TODO: to enable multiple nfts qtys or editions,
    //Mint requires an array of hashes and each metadata hash
    //has its own metadata such as serial numbers and other identifiers
    function mint(
        uint256 qty,
        address buyer,
        string memory buyerDid,
        bytes memory documentURI,
        bool encrypted,
        string memory name,
        string memory did
    ) public returns (bool) {
       // User must have a balance
        require(
            stablecoin.balanceOf(msg.sender) > 0,
            "Invalid token balance"
        );
        // User must have an allowance
        require(
            stablecoin.allowance(msg.sender, address(this)) > 0,
            "Invalid token allowance"
        );

        require(qty <= 20, "Quantity must be 20 or less");
        require(qty != 0, "Quantity must not be 0");
        publisherCount++;

        if (!minters[msg.sender].enabled) {
            minters[msg.sender] = Publisher({
                name: name,
                paymentAddress: msg.sender,
                did: did,
                hasUserKyc: false,
                enabled: true
            });
        }
        uint256 i = minterDocumentRequestCounter[msg.sender];

        // Assign request to minter
        // We should move to use XDV Worker Protocol
        minterDocumentRequests[msg.sender][i] = MintingRequest({
            //TODOs: implement quantity in existence
            //[Temporary for the demo] only 1 in existence for each nft 
            //later we could control the quantity at the minting
            publisher: msg.sender,
            buyer: buyer,
            buyerDid: buyerDid,
            documentURI: documentURI,
            status: uint256(DocumentMintingRequestStatus.MINTED),
            encrypted: encrypted,
            qty: qty
        });
        minterDocumentRequestCounter[msg.sender]++;

        emit DocumentAnchored(msg.sender, buyerDid, documentURI, i);

        
        for (uint j=0 ; j < qty ; j++){
            _tokenIds.increment();
            uint newItemId = _tokenIds.current();
            _safeMint(buyer, newItemId, documentURI);
        }
        return true;
    }

    /**
     * @dev Prevents the contract from working until `unpause()` is called.
     * Used for Emergencies.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev If the contract is `paused()`, this will allow it to work again.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Custom hook implementation.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Pausable, ERC721Enumerable) {
        // Minting by publisher
        if (from == address(0) && to != address(0)) {
            // Transfer tokens to pay service fee
            //When alice transfers to bob it must charge service fee
            require(
                stablecoin.transferFrom( //Klip marketplace fee
                    msg.sender,
                    address(this),
                    fee
                ),
                "KLIP: Transfer failed"
            );

            emit ServiceFeePaid(
                tokenId,
                msg.sender,
                msg.sender,
                fee,
                0
            );        
        }

        // Resale
        if (from == msg.sender && to != address(0)) {
            require(
                stablecoin.transferFrom( //Klip marketplace fee
                    msg.sender,
                    address(this),
                    fee
                ),
                "KLIP: Transfer failed"
            );

            // Pending royalty
            emit ServiceFeePaid(
                tokenId,
                msg.sender,
                msg.sender,
                fee,
                0
            );        
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev tries to execute the payment when the token is transfered.
     * Reverts if the payment procedure could not be completed.
     */
    function _paymentBeforeTransfer(address tokenHolder, uint256 tokenId)
        internal
        virtual
    {
        require(
            paymentAddress != address(0),
            "KLIP: Must have a payment address"
        );

        // Transfer tokens to pay service fee
        //When alice transfers to bob it must charge service fee
        require(
            stablecoin.transferFrom( //Klip marketplace fee
                msg.sender,
                address(this),
                fee
            ),
            "KLIP: Transfer failed"
        );
        require(
            stablecoin.transferFrom( // NFT/Product payment from minter to buyer
                tokenHolder,
                paymentAddress,
                royalty
            ),
            "KLIP: Transfer failed"
        );
        //TODO:
        //Might have to add the transfer for when
        //bob from bob to alice for when the nft is resold

        emit ServiceFeePaid(
            tokenId,
            tokenHolder,
            paymentAddress,
            fee,
            royalty
        );
    }

    function withdrawBalance(address payable payee) public onlyOwner {
        uint256 balance = stablecoin.balanceOf(address(this));

        require(stablecoin.transfer(payee, balance), "KLIP: Transfer failed");

        emit Withdrawn(payee, balance);
    }
}