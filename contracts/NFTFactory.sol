pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NFTFactory {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;
    using Address for address payable;

    // Emits when an document is created
    event LogMinterCreated(address indexed minter);
    event LogMinterRemoved(address indexed minter);
    event Withdrawn(address indexed payee, uint256 weiAmount);
    address public owner;
    uint256 fee = 0.002 * 1e18;

    // minters
    EnumerableSet.AddressSet internal minters;

    constructor() public {
        owner = msg.sender;
    }

    function setFee(uint256 _fee) public {
        require(msg.sender == owner, "INVALID_USER");
        fee = _fee;
    }

    function getFee() public returns (uint256) {
        return fee;
    }

    function withdraw(address payable payee) public {
        require(msg.sender == owner, "INVALID_USER");
        uint256 b = address(this).balance;
        payee.sendValue(address(this).balance);

        emit Withdrawn(payee, b);
    }

    // payWorkflowTemplate - payable
    function createMinter(string memory name, string memory symbol)
        public
        payable
        returns (address)
    {
        require(msg.value == fee, "MUST SEND FEE BEFORE USE");

        address minter =
            address(new NFTDocumentMinter(owner, msg.sender, name, symbol));
        bool ok = minters.add(minter);
        emit LogMinterCreated(minter);

        // TODO: transfer from

        return minter;
    }

    function count() public view returns (uint256) {
        return workflows.length();
    }

    function get(uint256 index) public view returns (address) {
        return workflows.at(index);
    }
}
