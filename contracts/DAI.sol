// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract DAI is ERC20PresetMinterPauser {
    constructor() ERC20PresetMinterPauser("DAI", "DAI") {
        mint(address(this), 1000000 ether);
    }
}
