// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 *  Register Minters  debe ir un mapping, un evento de add registry, un counter para 
 saber cuantos registros , get de fetch que debe recibir un address, y returnar un struct de vuelta
 */
contract XDVDocumentAnchoring {
    // Document by minter id sequence/autonumber
    mapping(address => uint256) public minterDocumentAnchorCounter;

    // Document by user address by id
    mapping(address => mapping(uint256 => DocumentAnchor))
        public minterDocumentAnchors;

    // Document Anchor
    struct DocumentAnchor {
        address user;
        string userDid;
        string documentURI;
        string description;
        uint256 timestamp;
    }

    // DocumentAnchored events
    event DocumentAnchored(
        address indexed user,
        string indexed userDid,
        string documentURI,
        uint256 id
    );

    function addDocument(
        string memory userDid,
        string memory documentURI,
        string memory description
    ) public payable returns (uint256 documentId) {
        minterDocumentAnchorCounter[msg.sender]++;
        uint256 i = minterDocumentAnchorCounter[msg.sender];

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
