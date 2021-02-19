pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./XDV.sol";
import "./MinterCore.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./ERC20Interface.sol";

contract XDVController is MinterCore {
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

    constructor(address stablecoin, address xdv)  {
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


        emit Withdrawn(payee, b);
    }

    function withdrawToken(address payable payee, address erc20token) public {
        require(msg.sender == owner, "INVALID_USER");
        uint256 balance = ERC20Interface(erc20token).balanceOf(address(this));

        // Transfer tokens to pay service fee
        require(
            ERC20Interface(erc20token).transfer(
                payee, 
                balance),
            "Transfer failed for base token"
        );

        emit Withdrawn(payee, balance);
    }

    /**
    * User requests anchored document to be process 
     */
   function requestDataProviderService(
        string memory minterDid,
        address minterAddress,
        string memory userDid,
        string memory documentURI,
        string memory description
    ) public payable returns(uint){

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


        require(
            token.transferFrom(
                msg.sender,
                address(this), 
                fee),
            "Transfer failed for fee"
        );

        // accounting[msg.sender] = accounting[msg.sender] + fee;
        // accounting[address(this)] = accounting[address(this)] + fee;

        uint i = minterDocumentRequestCounter[minterAddress];
            
        // Assign request to minter
        // We should move to use XDV Worker Protocol
        minterDocumentRequests[minterAddress][i] = DocumentMintingRequest({
            user: msg.sender, 
            userDid: userDid,
            documentURI: documentURI,
            status: uint(DocumentMintingRequestStatus.REQUEST),
            description: description,
            toMinterDid: minterDid,
            toMinter: minterAddress,
            timestamp: block.timestamp
        });
        minterDocumentRequestCounter[minterAddress]++;

        emit DocumentAnchored(msg.sender, userDid, documentURI, i);
        return i;
    }


    /**
    *  @dev Mints a platform token.
     */
   function mint(
       address user, 
       address tokenizationConfig,
       string memory tokenURI
    )
        public
        returns (uint256)
    {
        require(user != address(0), "Invalid address");

       // updates a request
        uint requestId = minterCounter[tokenizationConfig];
        minterDocumentRequests[tokenizationConfig][requestId]
        .status = uint(DocumentMintingRequestStatus.MINTED);
        
        minterCounter[tokenizationConfig] = minterCounter[tokenizationConfig] + 1;
        return platformToken.mint(user, tokenURI);
    }   

    /**
    *  @dev Burns a platform token.
     */
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

        require(
            dataProvider.feeStructure > 0,
            "Must have set a fee structure"
        );
        require(
            dataProvider.paymentAddress != address(0),
            "Must have a payment address"
        );
        require(
            dataProvider.factoryAddress != address(0),
            "Must have a factory address"
        );
        require(
            dataProvider.serviceFee > 0,
            "Must have set a service fee"
        );
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
            minterDocumentRequests[dataProvider.minterAddress][requestId]
            .status = uint(DocumentMintingRequestStatus.BURNED);
        }
        

        return true;
    }       

    /**
    * @dev Registers a data tokenization service
    *
     */
    function registerMinter(
        address minter,
        string memory name, 
        address paymentAddress,
        bool userHasKyc,
        uint feeStructure)
        public
        returns (uint)
    {
 
      minterCounter[minter]++;
        uint i = minterCounter[minter];
            
        dataProviderMinters[i] = DataProviderMinter({
            minterAddress: minter, 
            name: name,
            paymentAddress: paymentAddress,
            hasUserKyc: userHasKyc,
            feeStructure: feeStructure,
            created: block.timestamp,
            serviceFee: fee,
            factoryAddress: address(this),
            enabled: true
        });

        // whitelist
        platformToken.setWhitelistedMinter(msg.sender, false);

        emit MinterRegistered(minter, i, name);
        return i;
    }

    function count() public view returns (uint256) {
        return minters.length();
    }

    function get(uint256 index) public view returns (address) {
        return minters.at(index);
    }
}
