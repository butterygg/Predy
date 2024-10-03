// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MarketMaker.sol";
import "./Oracle.sol";
import "./ConditionalToken.sol";

contract Market {
    bytes32 public questionId;
    MarketMaker public marketMaker;
    Oracle public oracle;
    bool public isResolved;
    bool public outcome;

    constructor(bytes32 _questionId, ConditionalToken _passToken, ConditionalToken _failToken, Oracle _oracle) {
        questionId = _questionId;
        marketMaker = new MarketMaker(_passToken, _failToken);
        oracle = _oracle;
    }

    function resolveMarket() external {
        require(!isResolved, "Market already resolved");
        outcome = oracle.getAnswer(questionId);
        isResolved = true;
    }
}

 