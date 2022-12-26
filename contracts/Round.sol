// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.0 || ^0.8.0;

import "./interfaces/IGroup.sol";
import "./interfaces/ILot.sol";
import "./interfaces/IRound.sol";
import "./UniswapRouter/interfaces/IUniswapRouter.sol";


import "./libraries/Proof.sol";
import "./libraries/Math.sol";
import "./libraries/JumpSnap.sol";
import "./libraries/Params.sol";


import "./Lot.sol";
import "./UniswapRouter/UniswapRouter.sol";


contract Round {
    address addr;

    mapping(address => uint256) private players;
    uint256 timeCreation;
    address groupAddress;
    mapping(address => uint256) pendingPlayers;
    address[] pendingAddress;
    uint256 deposit;

    address lotAddr;
    address routerAddr;

    uint256 balancesSnap = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    uint256 paramsSnap = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    uint Spos = 0;
    uint Sneg = 0;

    uint MaxRange;

    uint duration;

    constructor(uint256 _deposit) {
        groupAddress = msg.sender;
        deposit = _deposit;
        addr = address(this);
    }

    
    fallback() external payable {}

    receive() external payable {}

    modifier onlyGroup() {
        require(msg.sender == groupAddress, "It`s not a group contract!");
        _;
    }

    function Enter(address _sender, uint256 _value) public onlyGroup {
        require(_value >= deposit, "Not enouth deposit");
        pendingPlayers[_sender] += _value;
        pendingAddress.push(_sender);
    }

    modifier onlyOwner() {
        IGroup group = IGroup(groupAddress);
        address own = group.GetOwner();
        require(msg.sender == own, "You`re not owner group");
        _;
    }

    function StartRound() external onlyGroup returns(uint, uint, uint, uint){
        uint8 i=0;
        for (i = 0; i < pendingAddress.length; i++) {
            balancesSnap = Math.xor(                            //////Это?!
                balancesSnap, uint256(keccak256(abi.encodePacked(uint256(uint160(pendingAddress[i])), deposit))));          
            uint psnap = Params.GetSnapParamPlayerOut(pendingAddress[i], 0, 0, 0, 0);
            paramsSnap = Math.xor(psnap, paramsSnap);
        }
    
        UniV3Router uni = new UniV3Router(address(this));
        uni.Deposit{value: address(this).balance}();
        routerAddr = address(uni);
        balancesSnap = uint256(keccak256(abi.encode(balancesSnap)));
        paramsSnap = uint256(keccak256(abi.encode(paramsSnap)));
        timeCreation = block.timestamp;
        duration = 0;

        MaxRange = deposit * pendingAddress.length;

        Spos = 3*deposit;
        Sneg = deposit/3;
        return (uni.getBalanceEth(), MaxRange, balancesSnap, paramsSnap);
    }

    function CreateLot() external onlyGroup returns(address){
        require(timeCreation!=0);
        Lot lot  = new Lot();
        lotAddr = address(lot);
        return lotAddr;
    }

    
    modifier enoughRes(Proof.ProofRes calldata proof){
        uint res = Proof.GetProofBalance(proof);
        require(res == balancesSnap, "Not proof");
        require(proof.price<=proof.balance, "Not enoung res");
        _;
    }

    function EnoughRes(Proof.ProofRes calldata proof)external view returns(bool, uint, uint){
        uint res = Proof.GetProofBalance(proof);
        if(res == balancesSnap&&proof.price<=proof.balance){
            return (true, balancesSnap, res);
        }
        else{
            return (false, balancesSnap, res);
        }
    }


    modifier checkValue(uint price, uint value){
        IUniV3Router router = IUniV3Router(routerAddr);
        require(price<MaxRange, "incorrect price");
        require(value <= router.getBalanceEth()*price/MaxRange, "incorrect value!");
        _;
    }

    function NewLot(
        address _lotAddr,
        Params.InitParams memory initParams,
        Proof.ProofRes calldata proofRes
    ) public onlyGroup returns(uint, uint){
        IUniV3Router router = IUniV3Router(routerAddr);
        require(initParams.value <= router.getBalanceEth()*proofRes.price/MaxRange, "incorrect value!");
        ILot lot = ILot(_lotAddr);
        uint lotSnap = lot.New(initParams.timeFirst, initParams.timeSecond, proofRes.owner, proofRes.price, initParams.value);
        balancesSnap = JumpSnap.SnapNew(proofRes.owner, proofRes.balance, proofRes.price, proofRes.Hres);
        return (lotSnap, balancesSnap);
    }

    function CorrectEp(
        address _lotAddr, 
        uint _newPrice,
        Proof.ProofEnoungPrice calldata _proofEP
        ) external view returns(bool, uint, uint){
        ILot lot = ILot(_lotAddr);
        return lot.CorrectPrice(_proofEP, _newPrice);
    }

    function BuyLot(
        address _lotAddr,
        Proof.ProofRes calldata _proofRes, 
        Proof.ProofEnoungPrice calldata _proofEP 
     ) public onlyGroup returns(uint, uint){
        ILot lot = ILot(_lotAddr);
        uint lotSnap = lot.Buy(_proofRes.owner, _proofRes.price, _proofEP);
        balancesSnap = JumpSnap.SnapBuy(
            _proofRes.owner,
            _proofRes.prevOwner,
            _proofRes.balance,
            _proofRes.prevBalance,
            _proofRes.price,
            _proofRes.Hd
        );
        return (lotSnap, balancesSnap);

    }

    function SendLot(
        address _lotAddr,
        Params.InitParams memory initParams
    ) public onlyGroup returns(uint amountOut, uint reserve){
        ILot lot = ILot(_lotAddr);
        lot.End(initParams);
        IUniV3Router uni = IUniV3Router(routerAddr);
        lot.SetInitBalance(uni.getBalanceEth());
        amountOut = uni.swapWETHToDAI(initParams.value);
        lot.SetReceiveTokens(amountOut);    
        reserve = uni.getBalanceEth();    
    }

    function GetSnapParamPlayer( 
        address _owner,
        uint _nwin,
        uint _n,
        uint _spos,
        uint _sneg 
        ) public pure returns(uint){
            return uint(keccak256(abi.encodePacked(_owner,  _nwin, _n, _spos, _sneg)));
        }


    function _updatePlus(
        uint _balance,
        Params.PlayerParams calldata _params,
        uint _delta,
        uint _price
        ) private view returns(uint, uint, bytes memory dataParams){
            //uint curbalance = _balance + ((MaxRange - _balance)*100*(_params.spos + _delta)/Spos)/100;
            uint curbalance = _balance + _price + ((MaxRange - _balance)*(_params.spos + _delta)/Spos);
            dataParams = abi.encode(_params.owner, 
                 _params.nwin +1, 
                 _params.n +1, 
                 _params.spos + _delta, 
                 _params.sneg);
            return (GetSnapParamPlayer(_params.owner, _params.nwin +1, 
                _params.n +1, _params.spos + _delta, _params.sneg), curbalance, dataParams);
        }

    function _updateMinus(
        uint _balance,
        Params.PlayerParams calldata _params,
        uint _delta
        ) private view returns(uint, uint, bytes memory dataParams){
            uint curbalance = _balance *(100 - 100*  (_params.sneg+_delta)/Sneg)/100;
            dataParams = abi.encode(_params.owner, 
                 _params.nwin, 
                 _params.n +1, 
                 _params.spos, 
                 _params.sneg+_delta);
            return (GetSnapParamPlayer(_params.owner, _params.nwin, 
                _params.n +1, _params.spos, _params.sneg + _delta), curbalance, dataParams);
    }

    modifier correctParams(Params.PlayerParams memory _params){
        uint snap = Params.GetSnapParamPlayer(_params);
        uint val = Math.xor(_params.Hp, snap);
        require(uint(keccak256(abi.encode(val)))==paramsSnap, "Not correct params");
        _;
    }
    function ReceiveLot(
        address _lotAddr,
        Params.InitParams calldata _init,
        Proof.ProofRes calldata _proof,
        Params.PlayerParams calldata _params
    )  public onlyGroup returns(bytes memory dataParams, uint newBalance, uint reserve){
        IUniV3Router router = IUniV3Router(routerAddr);
        ILot lot = ILot(_lotAddr);
        lot.Close(_init, _proof);
        uint receiveTokens = lot.GetReceiveTokens();
        router.swapDAItoWETH(receiveTokens);
        reserve = router.getBalanceEth();

        int res = int(router.getBalanceEth()) - int(lot.GetInitBalance());

        uint snapParams;

        if(res>=0){           
            Spos+=uint(res); 
            (snapParams, newBalance, dataParams) = _updatePlus(
                _proof.balance,
                _params, 
                uint(res),
                _proof.price);
            balancesSnap =  uint256(
                keccak256(
                    abi.encode(
                        Math.xor(
                            _proof.Hres, 
                            uint256(keccak256(abi.encodePacked(uint256(uint160(_params.owner)),  newBalance)))
                            ))));


            paramsSnap =  uint256(
                keccak256(
                    abi.encode(
                        Math.xor(
                            _params.Hp, 
                            snapParams
                            ))));
        }
        else{
            Sneg+=uint(Math.Abs(res));
            (snapParams, newBalance, dataParams) = _updateMinus(
                _proof.balance,
                _params, 
                uint(Math.Abs(res)));

            balancesSnap =  uint256(
                keccak256(
                    abi.encode(
                        Math.xor(
                            _proof.Hres, 
                            uint256(keccak256(abi.encodePacked(uint256(uint160(_params.owner)),  newBalance)))
                            ))));


            paramsSnap =  uint256(
                keccak256(
                    abi.encode(
                        Math.xor(
                            _params.Hp, 
                            snapParams
                            ))));

        }
    }

    function Withdraw(
        Params.PlayerParams calldata _params,
        Proof.ProofRes calldata _proof
        ) external onlyGroup returns(uint, uint){
        require(block.timestamp>timeCreation+duration, "it is too early");
        IUniV3Router uni = IUniV3Router(routerAddr);
        uint countOut = (uni.getBalanceEth()*100*_params.spos/Spos)/100;
        uni.withdraw(countOut);
        payable(msg.sender).transfer(countOut);

        uint snapParams =  Params.GetSnapNullPlayer(_params);
        paramsSnap =  uint256(
                keccak256(
                    abi.encode(
                        Math.xor(
                            _params.Hp, 
                            snapParams
                            ))));
        balancesSnap = uint256(
                keccak256(
                    abi.encode(
                        Math.xor(
                            _proof.Hres, 
                            uint256(keccak256(abi.encodePacked(uint256(uint160(_params.owner)), uint(0))))
                            ))));
        return (paramsSnap, balancesSnap);
    }

    function GetReserve() external view returns(uint){
        IUniV3Router uni = IUniV3Router(routerAddr);
        return uni.getBalanceEth();
    }

    function GetBalancesSnap() external view onlyGroup returns(uint){
        return balancesSnap;
    }
    function GetParamsSnap() external view onlyGroup returns(uint){
        return paramsSnap;
    }
}
