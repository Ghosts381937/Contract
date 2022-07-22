// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Sapphire is ERC20 {
    string constant public NAME = "Sapphire";
    string constant public SYMBOL = "SAPPHIRE";
    uint constant public INITIAL_SUPPLY = 10000000000000000000000;
    constructor() ERC20(NAME, SYMBOL) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}