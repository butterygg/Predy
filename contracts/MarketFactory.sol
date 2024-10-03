// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Oracle.sol";
import "./Market.sol";
import "./OutcomeToken.sol";

contract MarketFactory {
    Oracle public oracle;
    mapping(bytes32 => Market) public markets;

    constructor() {
        oracle = new Oracle();
    }

    function createMarket(bytes32 _questionId, bytes32 _tokenName) external returns (Market) {
        require(address(markets[_questionId]) == address(0), "Market already exists");

        Market newMarket = new Market(_questionId, _tokenName, oracle);
        markets[_questionId] = newMarket;

        return newMarket;
    }
}
