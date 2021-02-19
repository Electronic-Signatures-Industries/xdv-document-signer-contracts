pragma solidity ^0.7.0;

import "@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";

contract USDC is ERC20PresetMinterPauser {
    constructor() public ERC20PresetMinterPauser("USDC", "USDC") {
        mint(address(this), 1000000 ether);
    }
}
