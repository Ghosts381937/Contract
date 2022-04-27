// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    constructor(uint256 initialSupply) public ERC20("Gold", "GLD") {
        _mint(msg.sender, initialSupply);
    }
    function approve(address spender, uint256 amount)
        public
        override(ERC20)
        returns (bool)
    {
        return super.approve(spender, amount);
    }
    function transferFrom(address from, address to, uint256 amount)
        public
        override(ERC20)
        returns (bool)
    {
        return super.transferFrom(from, to, amount);
    }
    function transfer(address to, uint256 amount)
        public
        override(ERC20)
        returns (bool)
    {
        return super.transfer(to, amount);
    }
}