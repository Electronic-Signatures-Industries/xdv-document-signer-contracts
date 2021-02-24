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
    uint256 public fee;
    ERC20Interface public stablecoin;

    mapping(address => bool) public orders;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public accounting;

    event KYCPaid(address payer, address user);

    /**
     * DID Payment
     */
    constructor(address tokenAddress) public {
        owner = msg.sender;
        stablecoin = ERC20Interface(tokenAddress);
    }

    function setWhitelistedUser(address user, bool enable)
        public
        returns (bool)
    {
        require(msg.sender == owner, "INVALID_USER");
        whitelisted[user] = enable;
        return true;
    }

    function setProtocolConfig(uint256 _fee) public {
        require(msg.sender == owner, "INVALID_USER");
        fee = _fee;
    }

    function getProtocolConfig() public view returns (uint256) {
        return (fee);
    }

    /**
     * @dev Pays for KYC Service, supports pre-paid users
     */
    function payKYCService(address user) public payable returns (bool) {
        require(orders[user] == true, "User already paid");
        if (whitelisted[user] == false) {
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
                stablecoin.transferFrom(msg.sender, address(this), fee),
                "Transfer failed for fee"
            );
            accounting[msg.sender] = accounting[msg.sender] + fee;
            orders[msg.sender] = true;
        } else {
            accounting[user] = accounting[user] + 0;
            orders[user] = true;
        }
        // update accounting
        accounting[address(this)] = accounting[address(this)] + fee;

        // already paid
        emit KYCPaid(msg.sender, user);
        return true;
    }

    function verifyPayment(address user) public view returns (bool) {
        require(
            orders[user] == true,
            "No KYC payment found for current user"
        );
        return true;
    }
}
