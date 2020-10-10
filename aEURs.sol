// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/presets/ERC20PresetMinterPauser.sol";


contract aEURs is ERC20PresetMinterPauser {
    constructor() public ERC20PresetMinterPauser("aEURs", "Aave Euro stable") {}
}
