// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "hardhat/console.sol";


import "./interfaces/ISwapRouter.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IQuoter.sol";



contract UniV3Test {
    ISwapRouter constant router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    
    address constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address constant DAI = 0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844;
    uint24 constant fee = 3000;

    address roundAddr;

    constructor(){
        roundAddr = msg.sender;
    }

    modifier OnlyRound{
        require(msg.sender == roundAddr);
        _;
    }

    function swapWETHToDAI(uint amountIn) external OnlyRound returns(uint256 amountOut){
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

        amountOut = router.exactInputSingle(params);
    }

    function Enter() external payable{
        IWETH(WETH).deposit{value: msg.value}();
    }

    function ReadPrice(uint _amountIn) external returns(uint256){
        IQuoter quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
        return quoter.quoteExactInputSingle({
            tokenIn: WETH,
            tokenOut: DAI,
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