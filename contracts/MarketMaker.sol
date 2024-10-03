// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ConditionalToken.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract MarketMaker {
    using Math for uint256;

    ConditionalToken public passToken;
    ConditionalToken public failToken;
    uint256 public constant INITIAL_LIQUIDITY = 1e18;

    constructor(ConditionalToken _passToken, ConditionalToken _failToken) {
        passToken = _passToken;
        failToken = _failToken;
    }



    function deposit() external payable {
        uint256 amount = msg.value;
        passToken.mint(msg.sender, amount);
        failToken.mint(msg.sender, amount);

        if (passToken.totalSupply() == 0 && failToken.totalSupply() == 0) {
            passToken.mint(address(this), INITIAL_LIQUIDITY);
            failToken.mint(address(this), INITIAL_LIQUIDITY);
        }

    }

    function withdraw(uint256 amount) external {
        require(passToken.balanceOf(msg.sender) >= amount && failToken.balanceOf(msg.sender) >= amount, "Insufficient balance");

        passToken.burn(msg.sender, amount);
        failToken.burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);

    }

    function swap(bool buyPass, uint256 amountIn) external {
        require(amountIn > 0, "Amount must be greater than 0");

        uint256 passSupply = passToken.totalSupply();
        uint256 failSupply = failToken.totalSupply();

        uint256 amountOut;
        if (buyPass) {
            amountOut = calculateSwapAmount(failSupply, passSupply, amountIn);
            require(amountOut <= passSupply, "Insufficient liquidity");
            failToken.burn(msg.sender, amountIn);
            passToken.transfer(msg.sender, amountOut);
        } else {
            amountOut = calculateSwapAmount(passSupply, failSupply, amountIn);
            require(amountOut <= failSupply, "Insufficient liquidity");
            passToken.burn(msg.sender, amountIn);
            failToken.transfer(msg.sender, amountOut);
        }
    }

    function calculateSwapAmount(uint256 balanceIn, uint256 balanceOut, uint256 amountIn) internal pure returns (uint256) {
        uint256 k = balanceIn * balanceOut;
        uint256 amountOut = balanceOut - (k / (balanceIn + amountIn));
        return amountOut;
    }
}