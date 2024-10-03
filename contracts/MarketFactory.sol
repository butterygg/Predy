// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Oracle.sol";
import "./Market.sol";
import "./ConditionalToken.sol";

contract MarketFactory {
    Oracle public oracle;
    mapping(bytes32 => Market) public markets;

    constructor() {
        oracle = new Oracle();
    }

    function createMarket(bytes32 _questionId) external returns (Market) {
        require(address(markets[_questionId]) == address(0), "Market already exists");
        
        ConditionalToken passToken = new ConditionalToken("Pass Token", "PASS");
        ConditionalToken failToken = new ConditionalToken("Fail Token", "FAIL");
        
        Market newMarket = new Market(_questionId, passToken, failToken, oracle);
        markets[_questionId] = newMarket;
        
        return newMarket;
    }
}