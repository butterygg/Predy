// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OutcomeToken.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract MarketMaker {
    using Math for uint256;

    OutcomeToken public longToken;
    OutcomeToken public shortToken;

    constructor(OutcomeToken _longToken, OutcomeToken _shortToken) {
        longToken = _longToken;
        shortToken = _shortToken;
    }



    function deposit() external payable {
        uint256 amount = msg.value;
        longToken.mint(msg.sender, amount);
        shortToken.mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(longToken.balanceOf(msg.sender) >= amount && shortToken.balanceOf(msg.sender) >= amount, "Insufficient balance");

        longToken.burn(msg.sender, amount);
        shortToken.burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);

    }

    function swap(bool buyLong, uint256 amountIn) external {
        require(amountIn > 0, "Amount must be greater than 0");

        uint256 longSupply = longToken.totalSupply();
        uint256 shortSupply = shortToken.totalSupply();

        uint256 amountOut;
        if (buyLong) {
            amountOut = calculateSwapAmount(shortSupply, longSupply, amountIn);
            assert(amountOut <= longSupply);
            shortToken.burn(msg.sender, amountIn);
            longToken.transfer(msg.sender, amountOut);
        } else {
            amountOut = calculateSwapAmount(longSupply, shortSupply, amountIn);
            assert(amountOut <= shortSupply);
            longToken.burn(msg.sender, amountIn);
            shortToken.transfer(msg.sender, amountOut);
        }
    }

    function calculateSwapAmount(uint256 balanceIn, uint256 balanceOut, uint256 amountIn) internal pure returns (uint256) {
        uint256 k = balanceIn * balanceOut;
        uint256 amountOut = balanceOut - (k / (balanceIn + amountIn));
        return amountOut;
    }
}
