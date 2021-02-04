pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./NFTDocumentMinter.sol";

/**
 *  Register Minters  debe ir un mapping, un evento de add registry, un counter para 
 saber cuantos registros , get de fetch que debe recibir un address, y returnar un struct de vuelta
 */
contract MinterRegistry {
    // Documents by minter counters
    mapping(address => uint) public minterCounter;
    mapping(uint => DataProviderMinter) public dataProviderMinters;

// Minter Register

 // RequestMinting events
    event MinterRegistered(
        address minter, // NFT
        uint id,
        bytes name,
        bytes symbol

    );

// Document minting request
    struct DataProviderMinter {
        address minterAddress;
        bytes name;
        bytes symbol;
        address paymentAddress;
        bool hasUserKyc;
        uint feeStructure;
        uint created;   
    }


    function addToRegistry(
        address minter,
        bytes memory name,
        bytes memory symbol,
        address paymentAddress,
        bool hasUserKyc,
        uint feeStructure   
    ) public returns(uint){

    minterCounter[minter]++;
    uint i = minterCounter[minter];
        
    dataProviderMinters[i] = DataProviderMinter({
        minterAddress: minter, 
        name: name,
        symbol: symbol,
        paymentAddress: paymentAddress,
        hasUserKyc: hasUserKyc,
        feeStructure: feeStructure,
        created: block.timestamp
    });

    emit MinterRegistered(minter, i, name, symbol);
    return i;
    }

}

