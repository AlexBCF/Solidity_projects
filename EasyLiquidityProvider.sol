// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./UniswapInterface.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract EasyLiquidityProvider {
    address private constant UNISWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant UNISWAP_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    event AddedLiquidity(
        string message,
        uint amountTokenA,
        uint amountTokenB,
        uint liquidity
    );


    function _performSwap(
        address _tokenFrom,
        address _tokenTo,
        uint _amountFrom
    ) internal returns (uint[] memory) {
        IERC20(_tokenFrom).transferFrom(msg.sender, address(this), _amountFrom);
        IERC20(_tokenFrom).approve(UNISWAP_ROUTER, _amountFrom);

        address[] memory path;
        path = new address[](2);
        path[0] = _tokenFrom;
        path[1] = _tokenTo;

        return IUniswapV2Router(UNISWAP_ROUTER).swapExactTokensForTokens(
                   _amountFrom,
                   0,
                   path,
                   msg.sender,
                   block.timestamp
        );
        // returns an array containing the amount of the swapped token
        // and the amount of the recieved token
    }

    function _addLiquidity(
        address _tokenA,
        address _tokenB,
        uint _amountA,
        uint _amountB
    ) internal {
        uint balA = IERC20(_tokenA).balanceOf(msg.sender);
        uint balB = IERC20(_tokenB).balanceOf(msg.sender);

        require (balA >= _amountA);
        require (balB >= _amountB);

        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
        IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);

        IERC20(_tokenA).approve(UNISWAP_ROUTER, _amountA);
        IERC20(_tokenB).approve(UNISWAP_ROUTER, _amountB);
        IUniswapV2Router(UNISWAP_ROUTER).addLiquidity(
                _tokenA,
                _tokenB,
                _amountA,
                _amountB,
                0,
                0,
                address(this),
                block.timestamp
        );
    }
    function AddLiquidity(
        address _tokenA,
        address _tokenB,
        uint _amountA
    ) public { 

        uint half = _amountA/2;
        uint[] memory swappedA = _performSwap(_tokenA,_tokenB,half);
        _addLiquidity(_tokenA,_tokenB,swappedA[0],swappedA[1]);
    }
}
