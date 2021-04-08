// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

pragma experimental ABIEncoderV2;

import "./XDV.sol";
import "./MinterCore.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./ERC20Interface.sol";

contract XDVController is MinterCore {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;
    using Address for address payable;

    event Withdrawn(address indexed payee, uint256 weiAmount);
    address public owner;

    XDV private platformToken;
    ERC20Interface public token;

    // minters
    mapping(address => DataProviderMinter) internal minters;
    mapping(address => uint256) public dataProviderAccounting;

    constructor(address stablecoin, address xdv) {
        token = ERC20Interface(stablecoin);
        platformToken = XDV(xdv);
        owner = msg.sender;
    }

    function withdraw(address payable payee) public {
        require(msg.sender == owner, "INVALID_USER");
        uint256 b = address(this).balance;

        emit Withdrawn(payee, b);
    }

    function withdrawToken(address payable payee, address erc20token) public {
        require(msg.sender == owner, "INVALID_USER");
        uint256 balance = ERC20Interface(erc20token).balanceOf(address(this));

        // Transfer tokens to pay service fee
        require(
            ERC20Interface(erc20token).transfer(payee, balance),
            "Transfer failed for base token"
        );

        emit Withdrawn(payee, balance);
    }

    /**
     * User requests anchored document to be process
     */
    function requestDataProviderService(
        string memory minterDid,
        address minterAddress,
        string memory userDid,
        string memory documentURI,
        string memory description
    ) public returns (uint256) {
        // // User must have a balance
        // require(token.balanceOf(msg.sender) >= 0, "Invalid token balance");
        // // User must have an allowance
        // require(
        //     token.allowance(msg.sender, address(this)) >= 0,
        //     "Invalid token allowance"
        // );

        uint256 i = minterDocumentRequestCounter[minterAddress];

        // Assign request to minter
        // We should move to use XDV Worker Protocol
        minterDocumentRequests[minterAddress][i] = DocumentMintingRequest({
            user: msg.sender,
            userDid: userDid,
            documentURI: documentURI,
            status: uint256(DocumentMintingRequestStatus.REQUEST),
            description: description,
            toMinterDid: minterDid,
            toMinter: minterAddress,
            timestamp: block.timestamp
        });
        minterDocumentRequestCounter[minterAddress]++;

        emit DocumentAnchored(msg.sender, userDid, documentURI, i);
        return i;
    }

    /**
     *  @dev Mints a platform token.
     */
    function mint(
        uint256 requestId,
        address user,
        address dataProvider,
        string memory tokenURI
    ) public returns (uint256) {
        require(
            minterDocumentRequests[dataProvider][requestId].status ==
                uint256(DocumentMintingRequestStatus.REQUEST),
            "Document with invalid status"
        );
        require(user != address(0), "Invalid address");

        // updates a request
        minterDocumentRequests[dataProvider][requestId].status = uint256(
            DocumentMintingRequestStatus.MINTED
        );

        minterCounter[dataProvider] = minterCounter[dataProvider] + 1;
        return platformToken.mint(user, tokenURI);
    }

    /**
     * @dev Registers a data tokenization service
     *
     */
    function registerMinter(
        string memory name,
        address paymentAddress,
        bool userHasKyc,
        uint256 feeStructure
    ) public returns (uint256) {
        minterCounter[msg.sender]++;

        minters[msg.sender] = DataProviderMinter({
            name: name,
            paymentAddress: paymentAddress,
            hasUserKyc: userHasKyc,
            feeStructure: feeStructure,
            created: block.timestamp,
            factoryAddress: address(this),
            enabled: true
        });

        // set new minter
        emit MinterRegistered(msg.sender, name);
        return minterCounter[msg.sender];
    }
}
