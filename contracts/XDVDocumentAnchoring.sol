// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 *  Register Minters  debe ir un mapping, un evento de add registry, un counter para 
 saber cuantos registros , get de fetch que debe recibir un address, y returnar un struct de vuelta
 */
contract XDVDocumentAnchoring {
    // Document by minter id sequence/autonumber
    mapping(address => uint) public minterDocumentAnchorCounter;

// TODO: Remove, deprecated
    // Document by user address by id
    mapping(address => mapping(uint => DocumentAnchor)) public minterDocumentAnchors;

    // Doocument by doc id
    mapping(uint => DocumentAnchor) public multiApprovalDocumentAnchors;

    event Withdrawn(address indexed payee, uint256 weiAmount);
    address public owner;
    uint public fee;
    IERC20 public stablecoin;

    mapping (address => uint) public accounting;

    /**
    * XDV Data Token
    */
    constructor(
        address tokenAddress
    ) {
        owner = msg.sender;
        stablecoin = IERC20(tokenAddress);
    }

    function setStableCoin(address tokenAddress) public {
        require(msg.sender == owner, "INVALID_USER");
        stablecoin = IERC20(tokenAddress);
    }

    function withdraw(address payable payee) public {
        require(msg.sender == owner, "INVALID_USER");
        uint256 b = address(this).balance;

        emit Withdrawn(payee, b);
    }

    function withdrawToken(address payable payee, address erc20token) public {
        require(msg.sender == owner, "INVALID_USER");
        uint256 balance = IERC20(erc20token).balanceOf(address(this));

        // Transfer tokens to pay service fee
        require(
            IERC20(erc20token).transfer(payee, balance),
            "Transfer failed for base token"
        );

        emit Withdrawn(payee, balance);
    }

    function setProtocolConfig(uint256 _fee) public {
        require(msg.sender == owner, "INVALID_USER");
        fee = _fee;
    }

    function getProtocolConfig() public view returns (uint256) {
        return (fee);
    }
    // Document Anchor
    struct DocumentAnchor {
        address user;
        string userDid;
        string documentURI; 
        string description;
        uint timestamp;
        // address[] whitelistSigners;
    }

    // DocumentAnchored events
    event DocumentAnchored(
        address indexed user, 
        string indexed userDid,
        string documentURI,
        uint id
    );
// Case 0 - single
// Case 1 - get approvals
// Case 2 - quorum eg 3 of 5 - aggPeerSigning
    function peerSigning(
        uint docid,
        string memory userDid,
        string memory documentUri,
        bool isComplete
    ) public payable returns(uint) {
        // if docid exists
        // require(multiApprovalDocumentAnchors[docid].user != address(0));
        // if whitelist
        // TODO: .whitelist.length > 0

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


        require(
            stablecoin.transferFrom(
                msg.sender,
                address(this), 
                fee),
            "Transfer failed for fee"
        );

        accounting[msg.sender] = accounting[msg.sender] + fee;
        accounting[address(this)] = accounting[address(this)] + fee;

        minterDocumentAnchorCounter[msg.sender]++;
        uint i = minterDocumentAnchorCounter[msg.sender];
            
        multiApprovalDocumentAnchors[i].user = msg.sender;
        // TODO: Update other fields

        emit DocumentAnchored(msg.sender, userDid, documentUri, i);
        return i; 
    }
    function addDocument(
        string memory userDid,
        string memory documentURI,
        string memory description,
        address[] memory whitelist
    ) public payable returns(uint){

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


        require(
            stablecoin.transferFrom(
                msg.sender,
                address(this), 
                fee),
            "Transfer failed for fee"
        );

        accounting[msg.sender] = accounting[msg.sender] + fee;
        accounting[address(this)] = accounting[address(this)] + fee;

        minterDocumentAnchorCounter[msg.sender]++;
        uint i = minterDocumentAnchorCounter[msg.sender];
            
        multiApprovalDocumentAnchors[i] = DocumentAnchor({
            user: msg.sender, 
            userDid: userDid,
            documentURI: documentURI,
            description: description,
            timestamp: block.timestamp
            // TODO
            // whitelistSigners: whitelist
        });

        emit DocumentAnchored(msg.sender, userDid, documentURI, i);
        return i;
    }

}