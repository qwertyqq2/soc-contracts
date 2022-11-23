// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;



import "./interfaces/ISwapRouter.sol";
import "./interfaces/IQuoter.sol";
import "./interfaces/IERC20.sol";

import "hardhat/console.sol";


contract UniV3Router {
    ISwapRouter constant router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    
    address constant WETH = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889;
    address constant DAI = 0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F;
    uint24 constant fee = 3000;

    constructor(){}

    function swapWETHToDAI(uint amountIn) external returns(uint256){
        uint balWETH = IWETH(WETH).balanceOf(address(this));
        require(balWETH>=amountIn, "Not enough eth on contract");
        IERC20(WETH).approve(address(router), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH,
                tokenOut: DAI,
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        return router.exactInputSingle(params);
    }


    function swapDAItoWETH(uint amountIn) external returns(uint256){
        //uint balDAI = IERC20(DAI).balanceOf(address(this));
        //require(balDAI>=amountIn, "Not enough dai on contract");
        IERC20(DAI).approve(address(router), amountIn);
    
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH,
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        return router.exactInputSingle(params);
    } 



    function Deposit() external payable{
        console.log("start");
        IWETH(WETH).deposit{value: msg.value}();
    }

    function curPriceWETHtoDAI(uint _amountIn) external returns(uint256){
        IQuoter quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
        return quoter.quoteExactInputSingle({
            tokenIn: WETH,
            tokenOut: DAI,
            fee: fee,
            amountIn: _amountIn,
            sqrtPriceLimitX96: 0
        });
    }

    function curPriceDAItoWETH(uint _amountIn) external returns(uint256){
        IQuoter quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
        return quoter.quoteExactInputSingle({
            tokenIn: DAI,
            tokenOut: WETH,
            fee: fee,
            amountIn: _amountIn,
            sqrtPriceLimitX96: 0
        });
    }

    function getBalanceEth() external view returns(uint256){
        return IWETH(WETH).balanceOf(address(this));
    }

    function getBalanceDAI() external view returns(uint256){
        return IERC20(DAI).balanceOf(address(this));
    }
}

