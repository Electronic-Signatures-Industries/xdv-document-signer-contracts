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

    // Document by doc id
    mapping(uint => DocumentAnchor) public multiApprovalDocumentAnchors;

    //Whitelisting by docid by address
    mapping(uint => mapping( address => bool)) whitelistingStatus;

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

    enum DocumentAnchorStatus {
        NONE,
        INITIAL,
        APPROVED,
        COMPLETED,
        REJECTED
    }

    // Document Anchor
    struct DocumentAnchor {
        address user;
        string userDid;
        string documentURI; 
        string description;
        uint timestamp;
        address[] whitelistSigners;
        uint status;
    }

    // DocumentAnchored events
    event DocumentAnchored(
        address indexed user, 
        string indexed userDid,
        string indexed documentURI,
        string description,
        uint id
    );

    event DocumentPeerSigned(
        uint indexed docid,
        string indexed documentURI,
        string indexed userDid,
        uint status
    );

// Case 0 - single
// Case 1 - get approvals
// Case 2 - quorum eg 3 of 5 - aggPeerSigning
    function peerSigning(
        uint docid,
        string memory userDid,
        string memory documentURI,
        bool isComplete,
        string memory description
    ) public payable returns(bool) {
        // Docid must exist
        require(multiApprovalDocumentAnchors[docid].user != address(0), "Document Id doesn't exist");
        // Doc must have at least one address on its whitelist
        require(
            multiApprovalDocumentAnchors[docid].whitelistSigners.length <= 10 && 
            multiApprovalDocumentAnchors[docid].whitelistSigners.length > 0, 
            "Document doesn't have any whitelisted addresses"
        );
        // Doc status must be other than NONE (0)
        require(multiApprovalDocumentAnchors[docid].status != uint (DocumentAnchorStatus.NONE));
        
        require(whitelistingStatus[docid][msg.sender]==false,"Address already signed document");

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

            
        multiApprovalDocumentAnchors[docid].user = msg.sender;
        multiApprovalDocumentAnchors[docid].userDid = userDid;
        multiApprovalDocumentAnchors[docid].documentURI = documentURI;
        multiApprovalDocumentAnchors[docid].description = description;

        whitelistingStatus[docid][msg.sender] == true;
        if(isComplete){
            multiApprovalDocumentAnchors[docid].status = uint (DocumentAnchorStatus.COMPLETED);
        }else{
            multiApprovalDocumentAnchors[docid].status = uint (DocumentAnchorStatus.APPROVED);
        }

        multiApprovalDocumentAnchors[docid].status = uint (DocumentAnchorStatus.APPROVED);

        emit DocumentPeerSigned(docid, documentURI, userDid, multiApprovalDocumentAnchors[docid].status);
        return true; 
    }

    function addDocument(
        string memory userDid,
        string memory documentURI,
        string memory description,
        address[] memory peers,
        uint status
    ) public payable returns(uint){
        address[] memory whitelist = peers;

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

        // Whitelisting mapping population
        if(whitelist.length > 0){
            //Initializing whitelisting status
            for(uint j=0; j<whitelist.length; j++){
                whitelistingStatus[j][whitelist[j]] = false;
            }
        }

        multiApprovalDocumentAnchors[i] = DocumentAnchor({
            user: msg.sender, 
            userDid: userDid,
            documentURI: documentURI,
            description: description,
            timestamp: block.timestamp,
            whitelistSigners: whitelist,
            status: status
        });

        emit DocumentAnchored(msg.sender, userDid, documentURI, description, i);
        return i;
    }
}