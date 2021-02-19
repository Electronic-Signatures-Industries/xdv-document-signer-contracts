pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./XDV.sol";
import "./MinterRegistry.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./ERC20Interface.sol";

contract XDVController is MinterRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;
    using Address for address payable;

    event Withdrawn(address indexed payee, uint256 weiAmount);
    address public owner;
    uint256 fee;
    XDV private platformToken;
    ERC20Interface public token;

    // minters
    EnumerableSet.AddressSet internal minters;

    constructor(address stablecoin, address xdv) public {
        token = ERC20Interface(stablecoin);
        platformToken = XDV(xdv);
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
   function mint(address user, string memory tokenURI)
        public
        returns (uint256)
    {
        return platformToken.mint(user, tokenURI);
    }   

    function burn(uint requestId, uint tokenId)
        public
        payable
        returns (bool)
    {

        // User must have a balance
        require(
            token.balanceOf(msg.sender) >= 0,
            "Invalid token balance"
        );
        // User must have an allowance
        require(
            token.allowance(msg.sender, address(this)) >= 0,
            "Invalid token allowance"
        );

        /* require(
            token.balanceOf(msg.sender) == (mintingServiceFee.sum(protocolServiceFee)), 
            "MUST SEND FEE BEFORE USE");
        */

        uint index = minterCounter[address(this)];
        DataProviderMinter memory dataProvider = dataProviderMinters[index];
        
        platformToken.burn(tokenId);

        // TODO: Update accounting
        //  - create mappings to data provider accounting
        //  - create mappings to protocol fee accounting

        // Transfer tokens to NFT owner
        require(
            token.transferFrom(
                msg.sender, 
                dataProvider.paymentAddress, 
                dataProvider.feeStructure),
            "Transfer failed for base token"
        );

        // Transfer tokens to pay service fee
        require(
            token.transferFrom(
                msg.sender, 
                dataProvider.factoryAddress, 
                dataProvider.serviceFee),
            "Transfer failed for base token"
        );

        // TODO desplegar el fee de burn
        if (requestId > 0) {
            minterDocumentRequests[address(this)][requestId].status = uint(DocumentMintingRequestStatus.BURNED);
        }
        

        return true;
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
