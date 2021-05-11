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

    // Document by user address by id
    mapping(address => mapping(uint => DocumentAnchor)) public minterDocumentAnchors;

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
    }

    // DocumentAnchored events
    event DocumentAnchored(
        address indexed user, 
        string indexed userDid,
        string documentURI,
        uint id
    );

    function addDocument(
        string memory userDid,
        string memory documentURI,
        string memory description
    ) public payable returns(uint){

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
            
        minterDocumentAnchors[msg.sender][i] = DocumentAnchor({
            user: msg.sender, 
            userDid: userDid,
            documentURI: documentURI,
            description: description,
            timestamp: block.timestamp
        });

        emit DocumentAnchored(msg.sender, userDid, documentURI, i);
        return i;
    }

}