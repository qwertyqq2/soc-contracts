// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



import "./interfaces/ISwapRouter.sol";
import "./interfaces/IQuoter.sol";
import "./interfaces/IERC20.sol";

contract UniV3Router {

    address roundAddr;

    uint balanceWETH;
    uint balanceDAI;

    constructor(address _roundAddr){ roundAddr = _roundAddr; }

    function swapWETHToDAI(uint amountIn) external returns(uint256){
        require(balanceWETH>=amountIn, "not enought WETH");
        balanceWETH-=amountIn;
        balanceDAI+=2*amountIn;
        return 2*amountIn;
    }


    function swapDAItoWETH(uint amountIn) external returns(uint256){
        require(balanceDAI>=amountIn, "not enought DAI");
        balanceDAI-=amountIn;
        balanceWETH+=amountIn/2-20;
        return amountIn/2 - 20;
    } 



    function Deposit() external payable{
        balanceWETH+=msg.value;
    }

    function withdraw(uint _amount) external{
        require(msg.sender==roundAddr, "not a round");
        require(getBalanceEth()>_amount, "not enough WETH");
        balanceWETH -= _amount;
        payable(roundAddr).transfer(_amount);
    }

    function curPriceWETHtoDAI(uint _amountIn) external pure returns(uint256){
        return 2*_amountIn;
    }

    function curPriceDAItoWETH(uint _amountIn) external pure returns(uint256){
        return _amountIn/2;
    }

    function getBalanceEth() public view returns(uint256){
        return balanceWETH;
    }

    function getBalanceDAI() external view returns(uint256){
        return balanceDAI;
    }
}



// contract UniV3Router {

//     address roundAddr;

//     ISwapRouter constant router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    
//     //MUMBAI
//     address constant WETH = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889;
//     address constant DAI = 0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa;

//     //GOERLI
//     //address constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;  
//     //address constant DAI = 0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844;  
//     uint24 constant fee = 3000;

//     constructor(address _roundAddr){ roundAddr = _roundAddr; }

//     function swapWETHToDAI(uint amountIn) external returns(uint256){
//         uint balWETH = IWETH(WETH).balanceOf(address(this));
//         require(balWETH>=amountIn, "Not enough eth on contract");
//         IERC20(WETH).approve(address(router), amountIn);

//         ISwapRouter.ExactInputSingleParams memory params =
//             ISwapRouter.ExactInputSingleParams({
//                 tokenIn: WETH,
//                 tokenOut: DAI,
//                 fee: fee,
//                 recipient: address(this),
//                 deadline: block.timestamp,
//                 amountIn: amountIn,
//                 amountOutMinimum: 0,
//                 sqrtPriceLimitX96: 0
//             });

//         return router.exactInputSingle(params);
//     }


//     function swapDAItoWETH(uint amountIn) external returns(uint256){
//         IERC20(DAI).approve(address(router), amountIn);
    
//         ISwapRouter.ExactInputSingleParams memory params =
//             ISwapRouter.ExactInputSingleParams({
//                 tokenIn: DAI,
//                 tokenOut: WETH,
//                 fee: fee,
//                 recipient: address(this),
//                 deadline: block.timestamp,
//                 amountIn: amountIn,
//                 amountOutMinimum: 0,
//                 sqrtPriceLimitX96: 0
//             });
//         return router.exactInputSingle(params);
//     } 



//     function Deposit() external payable{
//         IWETH(WETH).deposit{value: msg.value}();
//     }

//     function withdraw(uint _amount) external{
//         require(msg.sender==roundAddr, "not a round");
//         require(getBalanceEth()>_amount, "not enough WETH");
//         IWETH(WETH).withdraw(_amount);
//         payable(roundAddr).transfer(_amount);
//     }

//     function curPriceWETHtoDAI(uint _amountIn) external returns(uint256){
//         IQuoter quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
//         return quoter.quoteExactInputSingle({
//             tokenIn: WETH,
//             tokenOut: DAI,
//             fee: fee,
//             amountIn: _amountIn,
//             sqrtPriceLimitX96: 0
//         });
//     }

//     function curPriceDAItoWETH(uint _amountIn) external returns(uint256){
//         IQuoter quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
//         return quoter.quoteExactInputSingle({
//             tokenIn: DAI,
//             tokenOut: WETH,
//             fee: fee,
//             amountIn: _amountIn,
//             sqrtPriceLimitX96: 0
//         });
//     }

//     function getBalanceEth() public view returns(uint256){
//         return IWETH(WETH).balanceOf(address(this));
//     }

//     function getBalanceDAI() external view returns(uint256){
//         return IERC20(DAI).balanceOf(address(this));
//     }
// }

