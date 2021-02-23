pragma solidity ^0.7.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC20Interface.sol";

/**
 * DID Payment - Accounting
 */
contract DIDPaymentService {
    address public owner;
    uint public fee;
    ERC20Interface public stablecoin;

    mapping(address => bool) public orders;
    mapping (address => uint) public accounting;

    event KYCPaid(
        address providerMinter
    );

    /**
    * DID Payment
    */
    constructor(address tokenAddress) public {
        owner = msg.sender;
        stablecoin  = ERC20Interface(tokenAddress);
    }

    function setProtocolConfig(uint256 _fee) public {
        require(msg.sender == owner, "INVALID_USER");
        fee = _fee;
    }

    function getProtocolConfig() public view returns (uint256) {
        return (fee);
    }    

    function payKYCService(
    ) public payable returns(bool){

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
        orders[msg.sender] = true;
        emit KYCPaid(msg.sender);
        return true;
    }

    function verifyPayment(
    ) public view returns(bool) {
        require(orders[msg.sender] == true, "No KYC payment found for current user");    
        return true;
    }

}