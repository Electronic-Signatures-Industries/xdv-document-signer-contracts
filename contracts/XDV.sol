// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC20Interface.sol";

contract XDV is ERC721, ERC721Pausable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    ERC20Interface public stablecoin;
    uint256 public serviceFeeForPaymentAddress = 0;
    uint256 public serviceFeeForContract = 0;
    address public paymentAddress;

    event ServiceFeePaid(
        address indexed from,
        address indexed paymentAddress,
        uint256 paidToContract,
        uint256 paidToPaymentAddress
    );

    /**
     * XDV Data Token
     */
    constructor(
        string memory name,
        string memory symbol,
        address tokenERC20,
        address newPaymentAddress
    ) ERC721(name, symbol) {
        paymentAddress = newPaymentAddress;
        stablecoin = ERC20Interface(tokenERC20);
    }

    function setServiceFeeForPaymentAddress(uint256 _fee) public onlyOwner {
        serviceFeeForPaymentAddress = _fee;
    }

    function setServiceFeeForContract(uint256 _fee) public onlyOwner {
        serviceFeeForContract = _fee;
    }

    function setPaymentAddress(address newAddress) public onlyOwner {
        paymentAddress = newAddress;
    }

    /**
     * @dev Mints a XDV Data Token if whitelisted
     */
    function mint(address user, string memory uri) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(user, newItemId);
        _setTokenURI(newItemId, uri);

        return newItemId;
    }

    /**
     * @dev Just overrides the superclass' function. Fixes inheritance
     * source: https://forum.openzeppelin.com/t/how-do-inherit-from-erc721-erc721enumerable-and-erc721uristorage-in-v4-of-openzeppelin-contracts/6656/4
     */
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    /**
     * @dev Just overrides the superclass' function. Fixes inheritance
     * source: https://forum.openzeppelin.com/t/how-do-inherit-from-erc721-erc721enumerable-and-erc721uristorage-in-v4-of-openzeppelin-contracts/6656/4
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC721, ERC721Pausable) {
        // Address can be 0 when minting the coin for the first time.
        // no fees are applicable in this edge case.
        if (from == address(0)) {
            super._beforeTokenTransfer(from, to, amount);
            return;
        }

        require(paymentAddress != address(0), "Must have a payment address");

        uint256 totalFees = serviceFeeForContract + serviceFeeForPaymentAddress;

        // User must have a balance
        require(
            stablecoin.balanceOf(msg.sender) >= totalFees,
            "Sender does not have enough token balance to transfer"
        );

        // User must have an allowance
        require(
            stablecoin.allowance(msg.sender, address(this)) >= totalFees,
            "Sender does not have enough allowance to transfer"
        );

        // Transfer tokens to pay service fee
        require(
            stablecoin.transferFrom(
                msg.sender,
                paymentAddress,
                serviceFeeForPaymentAddress
            ),
            "Transfer failed for payment address"
        );

        require(
            stablecoin.transferFrom(
                msg.sender,
                address(this),
                serviceFeeForContract
            ),
            "Transfer failed for payment address"
        );

        emit ServiceFeePaid(
            from,
            paymentAddress,
            serviceFeeForContract,
            serviceFeeForPaymentAddress
        );

        super._beforeTokenTransfer(from, to, amount);
    }
}
