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

    // TODO: implement LP fees
    // FIXME: Bookkeep the deposits
    function deposit(uint256 amount) external {
        require(longToken.allowance(msg.sender, address(this)) >= amount, "Insufficient long token allowance");
        require(shortToken.allowance(msg.sender, address(this)) >= amount, "Insufficient short token allowance");

        longToken.transferFrom(msg.sender, address(this), amount);
        shortToken.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) external {
        require(longToken.balanceOf(msg.sender) >= amount && shortToken.balanceOf(msg.sender) >= amount, "Insufficient balance");

        longToken.transfer(msg.sender, amount);
        shortToken.transfer(msg.sender, amount);
    }

    function swap(bool buyLong, uint256 amountIn) external {
        require(amountIn > 0, "Amount must be greater than 0");

        uint256 amountOut;
        if (buyLong) {
            amountOut = calculateSwapAmount(shortToken.balanceOf(address(this)), longToken.balanceOf(address(this)), amountIn);
            shortToken.transferFrom(msg.sender, address(this), amountIn);
            longToken.transfer(msg.sender, amountOut);
        } else {
            amountOut = calculateSwapAmount(longToken.balanceOf(address(this)), shortToken.balanceOf(address(this)), amountIn);
            longToken.transferFrom(msg.sender, address(this), amountIn);
            shortToken.transfer(msg.sender, amountOut);
        }
    }

    function calculateSwapAmount(uint256 reserveIn, uint256 reserveOut, uint256 amountIn) internal pure returns (uint256) {
        uint256 k = reserveIn * reserveOut;
        uint256 amountOut = reserveOut - (k / (reserveIn + amountIn));
        return amountOut;
    }
}
