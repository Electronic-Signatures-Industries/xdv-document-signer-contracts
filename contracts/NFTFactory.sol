pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./NFTDocumentMinter.sol";
import "./MinterRegistry.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./ERC20Interface.sol";

contract NFTFactory is MinterRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;
    using Address for address payable;

    // Emits when an document is created
    event MinterCreated(
        address indexed minter,
        string indexed name, 
        string indexed symbol,
        address paymentAddress,
        uint feeStructure
    );
    event MinterRemoved(address indexed minter);
    event Withdrawn(address indexed payee, uint256 weiAmount);
    address public owner;
    uint256 fee = 2 * 10e18;
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

    function createMinter(
        bytes memory name, 
        bytes memory symbol,
        address paymentAddress,
        bool userHasKyc,
        uint feeStructure)
        public
        returns (address)
    {

        address minter =
            address(new NFTDocumentMinter(
                owner, 
                msg.sender, 
                string(name), 
                string(symbol), 
                feeStructure, 
                fee,
                paymentAddress,
                address(this),
                daiToken));
        
        addToRegistry(
                minter, 
                name,
                symbol,
                paymentAddress,
                userHasKyc,
                feeStructure);
        
        bool ok = minters.add(minter);
        emit MinterCreated(
            minter,
            string(name),
            string(symbol),
            paymentAddress,
            feeStructure
        );

        // TODO: transfer from to owner (factory fee)

        return minter;
    }

    function count() public view returns (uint256) {
        return minters.length();
    }

    function get(uint256 index) public view returns (address) {
        return minters.at(index);
    }
}
