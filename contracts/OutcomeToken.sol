// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OutcomeToken is ERC20, Owned {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        setOwner(msg.sender);
    }

    function mint(address account, uint256 amount) onlyOwner external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) onlyOwner external {
        _burn(account, amount);
    }
}
