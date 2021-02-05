pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./NFTDocumentMinter.sol";
import "./MinterRegistry.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./ERC20Interface.sol";

contract NFTManager is MinterRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;
    using Address for address payable;

    event Withdrawn(address indexed payee, uint256 weiAmount);
    address public owner;
    uint256 fee;
    ERC20Interface public daiToken;

    // minters
    EnumerableSet.AddressSet internal minters;

    constructor(address dai) public {
        daiToken = ERC20Interface(dai);
        owner = msg.sender;
    }

    function setProtocolFee(uint256 _fee) public {
        require(msg.sender == owner, "INVALID_USER");
        fee = _fee;
    }

    function getProtocolFee() public returns (uint256) {
        return fee;
    }

    function withdraw(address payable payee) public {
        require(msg.sender == owner, "INVALID_USER");
        uint256 b = address(this).balance;
        payee.sendValue(address(this).balance);

        emit Withdrawn(payee, b);
    }

    function withdrawToken(address payable payee, address token) public {
        require(msg.sender == owner, "INVALID_USER");
        uint256 b = ERC20Interface(token).balanceOf(address(this));
        payee.sendValue(b);

        emit Withdrawn(payee, b);
    }

    function registerMinter(
        address minter,
        string memory name, 
        string memory symbol,
        address paymentAddress,
        bool userHasKyc,
        uint feeStructure)
        public
        returns (address)
    {
 
        addToRegistry(
            minter, 
            name,
            symbol,
            paymentAddress,
            userHasKyc,
            feeStructure,
            fee,
            address(this));

        return minter;
    }

    function count() public view returns (uint256) {
        return minters.length();
    }

    function get(uint256 index) public view returns (address) {
        return minters.at(index);
    }
}
