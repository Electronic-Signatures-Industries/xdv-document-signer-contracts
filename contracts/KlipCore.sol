// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

abstract contract KlipCore is IERC1271, Ownable {
    enum DocumentMintingRequestStatus {REQUEST, MINTED, BURNED}

    // Document minting request
    struct MintingRequest {
        address publisher;
        address buyer; // NFT
        string buyerDid;
        bytes documentURI;
        uint256 status;
        bool encrypted;
        uint256 qty;
    }

    // Document minting provider
    struct Publisher {
        string name;
        address paymentAddress;
        string did;
        bool hasUserKyc;
        //uint256 feeStructure;
        //address factoryAddress;
        bool enabled;
    }

    // DocumentAnchored events
    event DocumentAnchored(
        address indexed publisher,
        string indexed publisherDid,
        bytes documentURI,
        uint256 id
    );
    
    //TODO: Evaluate if an aditional metadata mapping is required
    constructor () {

    }

    uint256 public publisherCount;
    mapping(address => Publisher) internal minters;

    // Documents provider mappings
    mapping(address => uint256) public minterCounter;

    // Requested Documents by minter id sequence/autonumber
    mapping(address => uint256) public minterDocumentRequestCounter;

    // Requests by minter by autonumber
    mapping(address => mapping(uint256 => MintingRequest))
        public minterDocumentRequests;

    /**
     * @dev ERC-1271 Compatibility. This checks that the message signature was sent by the
     * contract's owner. Inspired by this implementation:
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/mocks/ERC1271WalletMock.sol
     * @return magicValue either 0x00000000 for false or 0x1626ba7e for true.
     * 0x1626ba7e == bytes4(keccak256("isValidSignature(bytes32,bytes)")
     */
    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        override
        returns (bytes4 magicValue)
    {
        address signer = ECDSA.recover(hash, signature);
        return signer == owner() ? this.isValidSignature.selector : bytes4(0);
    }
    
}