// SPDX-License-Identifier: MIT
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
    uint256 public serviceFeeForPaymentAddress = 0;
    uint256 public serviceFeeForContract = 0;
    address public paymentAddress;

    event ServiceFeePaid(
        address indexed from,
        address indexed paymentAddress,
        uint256 paidToContract,
        uint256 paidToPaymentAddress
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "INVALID_USER");
        _;
    }

    /**
     * XDV Data Token
     */
    constructor(
        string memory name,
        string memory symbol,
        address tokenERC20,
        address newPaymentAddress
    ) ERC721(name, symbol) {
        owner = msg.sender;
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        // Address can be 0 when minting the coin for the first time.
        // no fees are applicable in this edge case.
        if (from == address(0)) {
            super._beforeTokenTransfer(from, to, amount);
            return;
        }

        require(paymentAddress != address(0), "Must have a payment address");

        uint256 totalFees =
            serviceFeeForContract.add(serviceFeeForPaymentAddress);

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
