// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/token/ERC20/ERC20.sol";

contract aDai is ERC20 {
    constructor() ERC20("Aave Dai", "aDai") public {
        _mint(msg.sender, 10000000000000000000000000);
    }
}
