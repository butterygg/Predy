// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OutcomeToken.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract MarketMaker {
    using Math for uint256;

    OutcomeToken public longToken;
    OutcomeToken public shortToken;

    uint256 public constant INITIAL_RESERVE = 1e20; // 100 tokens
    uint256 public longReserve;
    uint256 public shortReserve;


    constructor(OutcomeToken _longToken, OutcomeToken _shortToken) {
        longToken = _longToken;
        shortToken = _shortToken;

        // Initialize reserves
        longReserve = INITIAL_RESERVE;
        shortReserve = INITIAL_RESERVE;
        
        // Mint initial tokens to this contract
        longToken.mint(address(this), INITIAL_RESERVE);
        shortToken.mint(address(this), INITIAL_RESERVE);

    }

    function deposit() external payable {
        uint256 amount = msg.value;

        require(amount <= longReserve && amount <= shortReserve, "Insufficient reserve");

        longToken.transfer(msg.sender, amount);
        shortToken.transfer(msg.sender, amount);

        longReserve -= amount;
        shortReserve -= amount;

    }

    function withdraw(uint256 amount) external {
        require(longToken.balanceOf(msg.sender) >= amount && shortToken.balanceOf(msg.sender) >= amount, "Insufficient balance");

        longToken.transferFrom(msg.sender, address(this), amount);
        shortToken.transferFrom(msg.sender, address(this), amount);
        
        longReserve += amount;
        shortReserve += amount;

        payable(msg.sender).transfer(amount);
    }

    function swap(bool buyLong, uint256 amountIn) external {
        require(amountIn > 0, "Amount must be greater than 0");


        uint256 amountOut;
        if (buyLong) {
            amountOut = calculateSwapAmount(shortReserve, longReserve, amountIn);
            shortToken.transferFrom(msg.sender, address(this), amountIn);
            longToken.transfer(msg.sender, amountOut);
            shortReserve += amountIn;
            longReserve -= amountOut;
        } else {
            amountOut = calculateSwapAmount(longReserve, shortReserve, amountIn);
            longToken.transferFrom(msg.sender, address(this), amountIn);
            shortToken.transfer(msg.sender, amountOut);
            longReserve += amountIn;
            shortReserve -= amountOut;

        }
    }

    function calculateSwapAmount(uint256 reserveIn, uint256 reserveOut, uint256 amountIn) internal pure returns (uint256) {
        uint256 k = reserveIn * reserveOut;
        uint256 amountOut = reserveOut - (k / (reserveIn + amountIn));
        return amountOut;
    }
}
