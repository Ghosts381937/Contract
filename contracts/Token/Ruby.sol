// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Ruby is ERC20 {
    string constant public NAME = "Ruby";
    string constant public SYMBOL = "RUBY";
    uint constant public INITIAL_SUPPLY = 10000000000000000000000;
    constructor() ERC20(NAME, SYMBOL) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}