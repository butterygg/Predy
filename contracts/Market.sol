// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MarketMaker.sol";
import "./Oracle.sol";
import "./OutcomeToken.sol";

contract Market {
    bytes32 public questionId;
    MarketMaker public marketMaker;
    Oracle public oracle;
    bool public isResolved;
    bool public outcome;
    OutcomeToken longToken;
    OutcomeToken shortToken;

    constructor(bytes32 _questionId, OutcomeToken _longToken, OutcomeToken _shortToken, Oracle _oracle) {
        questionId = _questionId;
        // FIXME: "Funded-Long-Project-Metric"
        OutcomeToken longToken = new OutcomeToken("Long Token", "LONG");
        OutcomeToken shortToken = new OutcomeToken("Short Token", "SHRT");

        marketMaker = new MarketMaker(_longToken, _shortToken);
        oracle = _oracle;
    }

    function split() external payable {
        uint256 amount = msg.value;
        
        longToken.mint(msg.sender, amount);
        shortToken.mint(msg.sender, amount);
    }

    function merge(uint256 amount) external {
        require(longToken.balanceOf(msg.sender) >= amount && shortToken.balanceOf(msg.sender) >= amount, "Insufficient balance");

        longToken.burn(msg.sender, amount);
        shortToken.burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }

    function resolveMarket() external {
        require(!isResolved, "Market already resolved");
        outcome = oracle.getAnswer(questionId);
        isResolved = true;
    }
}

