// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./libraries/SafeERC20.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor (){
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
interface IUniswapV2Factory {
    function owner() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
    external
    payable
    returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Pair {
    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external
    view
    returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Router is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}


interface IJUMPBonusPool {
    function addTick(address user,uint256 mintTotal) external payable;
    function getEndBonusTime() external view returns(uint256);
    function startTime() external view returns(uint256);
}

contract JUMPTreasury is ReentrancyGuard,Ownable{
    using SafeERC20 for IERC20;
    // Info of each token lq.
    struct TokenLqInfo{
        uint256 ethAddAmount; //add eth amount
        uint256 tokenAddAmount; //add token amount
        uint256 lqAmountTotal;
        uint256 addLqTime;
        uint256 rmLqAmount;
        bool isLiqWar;
        bool isStartLiqWar;
        bool isCTOFlag;
    }

    // Info of each user.
    struct UserInfo {
        uint256 depositAmount;   // How many tokens the user has provided.
        uint256 mintTotal; // How many mint tokens the user will receive.
        uint256 mintReleased;
        bool isRefund;
        bool isStartClaim;
    }

    struct LiqWarInfo{
        uint256 rewardETH;
        uint256 rewardSeq;
        address[2] rewardTokenAddrs;
        bool rmFlag;
    }

    address public JUMPToken;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public constant basePoints = 100;
    uint256 public constant refundRate =  75;
    uint256 public constant rmLiqWarRate = 10;
    uint256 public constant buyTokenCnt = 24;

    uint256 public bonusRate = 7;
    uint256 public marketMakerRate = 25;
    uint256 public rmSlippage = 5;

    uint256 public adLPRate = 15;
    uint256 public inviteRate = 3;

    uint256 public  protectLQDuration = 24 * 3600;
    uint256 public  protectRefundDuration = 7 * 24 * 3600;
    uint256 public  minPerDeposit;


    uint256 public  mintTokenLimit;
    uint256 public  addLQTokenLimit;
    uint256 public  mintedToken;
    uint256 public  mintLimitETH;
    uint256 public debitTotal;
    uint256 public debitLimit;

    uint256 public  userDepositTotal;
    mapping(address => bool) public keeperMap;

    // address => amount
    mapping(address => UserInfo) public userInfo;
    mapping(address => address) public tokenPair;
    mapping(address => TokenLqInfo) public tokenLqInfo;

    address public marketMakerAddr;
    address public inviteRewardAddr;

    mapping(address => uint256) public tokenDebitLevel;
    mapping(address => address) public tokenUser;
    mapping(uint256 => LiqWarInfo) public seqLiqWarInfo;

    uint256 public rangeIndex;

    uint256[20] public  buyRange;
    uint256[20] public  mintRange;

    address public WETH;
    IUniswapV2Factory public  factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f); //ETH;
    IUniswapV2Router public  swapRouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //ETH;
    IJUMPBonusPool public bonusPool;

    // The time when debit starts
    uint256 public startTime;
    // The time when debit ends
    uint256 public endTime;
    bool public isDestroyToken;
    address  public lockLPAddr;

    event AddNewDebit(address user,address newToken,address pair,uint256 debitLevel,uint256 initBuyAmount);

    event Donate(address indexed user, uint256 amount,uint256 range, uint256 userDeposit);
    event Claim(address indexed user, uint256 amount);
    event SetKeeper(address indexed sender,address addr,bool active);


   event RemoveLiqWarLiquidity(uint256 seqNo,address tokenAddr,address pair,uint256 lqAmount,uint256 ethAmount);
   event AddLiquidity(address tokenAddr,address pair,uint256 tokenAmount,uint256 ethAmount);
   event WithdrawDebitForLiqWar(address tokenAddr,address pair,uint256 lqAmount,uint256 ethAmount,bool isLiqWar);
   event RefundETH(address user, uint256 depositAmount,uint256 refundAmount);
   event RemoveLiqWarFlag(address sender,address tokenAddr);
   event SetRmLqSlippage(address sender,uint256 rmSlippage);
   event SetDebitLimit(address sender,uint256 debitLimit);
   event SetBonusPool(address sender,address bonusPool);

    modifier onlyKeeper() {
        require(isKeeper(msg.sender), "Not keeper");
        _;
    }


    constructor(address _v2Factory,address _v2Router,address _bonusPool,address _rewardAddr,address _JUMPToken) {
        swapRouter = IUniswapV2Router(_v2Router);
        factory = IUniswapV2Factory(_v2Factory);
        bonusPool = IJUMPBonusPool(_bonusPool);
        WETH = swapRouter.WETH();

        mintTokenLimit =  800_000_000e18;
        addLQTokenLimit = 120_000_000e18;

        mintLimitETH = 101287e17;
        minPerDeposit = 1e17; //0.1 ETH

        marketMakerAddr = 0xFE49c3D7b7EF988233FAddeD69f7B624A392E017;
        inviteRewardAddr = _rewardAddr;

        startTime = bonusPool.startTime();
        endTime = bonusPool.getEndBonusTime();

        JUMPToken = _JUMPToken;

        buyRange = [4600e17,9246e17,13938e17,18678e17,23465e17,28299e17,33182e17,38114e17,43095e17,48126e17,53207e17,58340e17,63523e17,68758e17,74046e17,79386e17,84780e17,90228e17,95730e17,101287e17];
        mintRange = [8695652174e13,8609556608e13,8524313473e13,8439914330e13,8356350822e13,8273614675e13,8191697698e13,8110591780e13,8030288891e13,7950781080e13,7872060476e13,7794119283e13,7716949785e13,7640544341e13,7564895388e13,7489995433e13,7415837063e13,7342412933e13,7269715776e13,7197738392e13];

        keeperMap[msg.sender] = true;
        lockLPAddr = 0xFE49c3D7b7EF988233FAddeD69f7B624A392E017;

    }

    function addNewDebit(address newToken,address user,uint256 debitLevel,bool isLiqWar) public payable onlyKeeper returns(address pair) {
        require(address(this).balance >= debitLevel,'Balance less than debit level');
        require(debitTotal + debitLevel <= debitLimit && (debitLimit > 0),'Exceed debitLimit');
        tokenDebitLevel[newToken] = debitLevel;
        tokenUser[newToken] = user;
        tokenLqInfo[newToken].isLiqWar = isLiqWar;
        _addLiquidity(newToken);
        uint256 initBuyAmount = msg.value;
        //swap buy
        address[] memory path = new address[](2);
        path[0] = address(WETH);
        path[1] = address(newToken);
        swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value:initBuyAmount}(
            0,
            path,
            user,
            block.timestamp
        );
        debitTotal += debitLevel;
        pair = tokenPair[newToken];
        emit AddNewDebit(user,newToken,pair,debitLevel,initBuyAmount);
    }

    function donate(uint256 donateNum) external payable nonReentrant{
        uint256 amount = msg.value;
        require(block.timestamp <= endTime,'Deposit end');
        require(amount >= minPerDeposit,'Less minPerDeposit');
        require(donateNum * minPerDeposit == amount,'Donate amount not equal to value');
        require(0 == amount % minPerDeposit,'Amount wrong');
        require(userDepositTotal + amount <= mintLimitETH,'Exceed ETH Limit');
        (uint256 tokenAmount,uint256 index,,) = getMintIndexAndAmount(userDepositTotal,amount);

        rangeIndex = index;
        address user = msg.sender;
        userDepositTotal += amount;
        userInfo[user].depositAmount += amount;
        userInfo[user].mintTotal += tokenAmount;
        mintedToken += tokenAmount;

        uint256 bonusPoolAmount = amount * bonusRate / basePoints;
        bonusPool.addTick{value: bonusPoolAmount}(msg.sender,userDepositTotal);
        endTime = bonusPool.getEndBonusTime();

        //marketMakerRate && add LP
        uint256 marketMakerAmount = amount * (marketMakerRate + adLPRate) / basePoints;
        (bool success, ) = marketMakerAddr.call{value: marketMakerAmount}("");
        require(success, "marketMaker Fail to refund ETH");

        //invite
        uint256 inviteETH = amount * inviteRate / basePoints;
        (bool success2, ) = inviteRewardAddr.call{value: inviteETH}("");
        require(success2, "invite Fail to refund ETH");
        if(userDepositTotal == mintLimitETH){
            endTime = block.timestamp;
        }
        emit Donate(msg.sender, amount, rangeIndex, userDepositTotal);
    }

    function refundETH() public nonReentrant{
        require(block.timestamp > endTime && block.timestamp <= endTime + protectRefundDuration,'Protect Refund Duration');
        address user = msg.sender;
        require(userInfo[user].depositAmount  > 0,'Without Deposit');
        require(!userInfo[user].isRefund && !userInfo[user].isStartClaim,'Has Refunded');
        uint256 refundAmount = userInfo[user].depositAmount * refundRate / basePoints;
        userInfo[user].isRefund = true;
        (bool success, ) = user.call{value: refundAmount}("");
        require(success, "Unable to refund ETH");
        IERC20(JUMPToken).safeTransfer(DEAD,userInfo[user].mintTotal);

        emit RefundETH(user,userInfo[user].depositAmount,refundAmount);
    }
    //After start claim, then claim the offering token
    function claim() public nonReentrant {
        address user = msg.sender;
        require(userInfo[user].depositAmount  > 0,'Without Deposit');
        require(block.timestamp > endTime,'Mint Not Finished');
        require(!userInfo[user].isRefund,'Has Refunded');
        require(userInfo[user].mintTotal > userInfo[user].mintReleased,'All Released');
        //claim release token
        uint canRelease = userInfo[user].mintTotal - userInfo[user].mintReleased;
        userInfo[user].mintReleased += canRelease;
        IERC20(JUMPToken).safeTransfer(user,canRelease);
        userInfo[user].isStartClaim = true;
        emit Claim(user, canRelease);
    }

    // get the amount of IDO token you will get
    function getOfferingAmount(address user) public view returns(uint256 userOfferingTotalAmount) {
        if(userInfo[user].isRefund){
            return 0;
        }
        userOfferingTotalAmount = userInfo[user].mintTotal;
    }

    function getMintAndLQInfo() public view returns(uint256 mintJUMPLimit,uint256 addLqJUMP,uint256 mintedJUMP){
        mintJUMPLimit = mintTokenLimit;
        addLqJUMP = addLQTokenLimit;
        mintedJUMP = mintedToken;
    }
    function getCanReleaseInfo(address user) public view returns (uint256 total, uint256 canRelease, uint256 released,uint256 locked) {
        total = userInfo[user].mintTotal;
        released = userInfo[user].mintReleased;
        if(block.timestamp <= endTime){
            return (total,0,0,total);
        }
        if(userInfo[user].isRefund){
            return (0,0,0,0);
        }
        if (uint128(block.timestamp) >= endTime) {
            canRelease = total - released;
        }
        locked = (total > canRelease + released) ? (total-canRelease-released) : 0;
    }

    function _addLiquidity(address tokenAddr) internal{
        require(tokenPair[tokenAddr] == address(0),'LQ added');
        uint256 currentEth = address(this).balance;
        uint256 tokenAmount = IERC20(tokenAddr).balanceOf(address(this));
        uint256 ethAmount = tokenDebitLevel[tokenAddr];
        require(currentEth >= ethAmount,'Amount exceed current ETH');
        uint256 beforeEth = address(this).balance;
        IERC20(tokenAddr).safeApprove(address(swapRouter), tokenAmount);
        (,,uint lq) = swapRouter.addLiquidityETH{value: ethAmount}(tokenAddr, tokenAmount,0,0,address(this), block.timestamp);
        //update lq info;
        address pair = factory.getPair(tokenAddr,address(WETH));
        tokenPair[tokenAddr] = pair;
        uint256 afterEth = address(this).balance;
        tokenLqInfo[tokenAddr].lqAmountTotal = lq;
        tokenLqInfo[tokenAddr].ethAddAmount = beforeEth - afterEth;
        tokenLqInfo[tokenAddr].tokenAddAmount = tokenAmount;
        tokenLqInfo[tokenAddr].addLqTime = block.timestamp;

        emit AddLiquidity(tokenAddr,pair,tokenAmount,ethAmount);
    }

    function withdrawDebitsForLiqWar(address[] memory tokenAddrs) public nonReentrant onlyKeeper{
        for(uint256 i = 0; i < tokenAddrs.length;i++){
            address tokenAddr = tokenAddrs[i];
            require(tokenLqInfo[tokenAddr].isLiqWar,'Not LiqWar token');
            _removeLiquidity(tokenAddrs[i],true);
        }
    }

    function withdrawDebitsForWithoutLiqWar(address[] memory tokenAddrs) public nonReentrant onlyKeeper{
        for(uint256 i = 0; i < tokenAddrs.length;i++){
            address tokenAddr = tokenAddrs[i];
            require(!tokenLqInfo[tokenAddr].isLiqWar,'LiqWar token');
            _removeLiquidity(tokenAddr,false);
        }
    }
    //Liqwar handle: remove failed tokens and mark two reward tokens
    function startLiqWarHandle(uint256 seqNo,address[] memory rmTokenAddrs,address[2] calldata rewardTokenAddrs) public nonReentrant onlyKeeper{
        require(!seqLiqWarInfo[seqNo].rmFlag,'seqNo has used');
        for(uint256 i = 0; i < rmTokenAddrs.length;i++){
            address tokenAddr = rmTokenAddrs[i];
            require(tokenLqInfo[tokenAddr].isStartLiqWar,'Not allow to Start LiqWar');
            _removeLiqWarLiquidity(seqNo,tokenAddr);
            seqLiqWarInfo[seqNo].rewardTokenAddrs = rewardTokenAddrs;
        }
    }

    //remove the LiqWar Flag &&  set CTO Flag
    function removeLiqWarFlag(address[] calldata tokenAddrs) public nonReentrant onlyKeeper {
        for(uint256 i =0;i < tokenAddrs.length; i++){
            _removeLiqWarFlag(tokenAddrs[i]);
        }
    }

    function _removeLiqWarFlag(address tokenAddr) internal {
        require(tokenLqInfo[tokenAddr].isStartLiqWar,'remove LiqWar Flag wrong');
        require(tokenLqInfo[tokenAddr].isLiqWar,'Not LiqWar token');
        tokenLqInfo[tokenAddr].isStartLiqWar = false;
        tokenLqInfo[tokenAddr].isCTOFlag = true;
        address pair = tokenPair[tokenAddr];
        uint256 lqBalance = IERC20(pair).balanceOf(address(this));
        if(lqBalance > 0){
            IERC20(pair).safeTransfer(DEAD, lqBalance);
        }
        emit RemoveLiqWarFlag(msg.sender,tokenAddr);
    }

    function _removeLiquidity(address tokenAddr,bool flag) internal {
        address pair = tokenPair[tokenAddr];
        uint256 lqBalance = IERC20(pair).balanceOf(address(this));
        //get reserve
        {
            require(!tokenLqInfo[tokenAddr].isStartLiqWar,'Start LiqWar');
            uint256 lqTotal = IERC20(pair).totalSupply();
            (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
            uint256 reserveEth = (address(WETH) > tokenAddr) ? reserve1 : reserve0;
            uint256 ethAmount = tokenDebitLevel[tokenAddr];
            uint256 amountOutETHMin = (ethAmount +  ethAmount * rmSlippage / basePoints) * (basePoints - rmSlippage) / basePoints;
            require(block.timestamp >= tokenLqInfo[tokenAddr].addLqTime + protectLQDuration,'RemoveLiquidity condition fail');
            uint256 lqAmount = (ethAmount +  ethAmount * rmSlippage / basePoints) * lqTotal / reserveEth;
            if(lqAmount > lqBalance){
                lqAmount = lqBalance;
                amountOutETHMin = 0;
            }
            IERC20(pair).safeApprove(address(swapRouter), lqAmount);
            (,uint amountETH) = swapRouter.removeLiquidityETH(tokenAddr,lqAmount,0,amountOutETHMin,address(this), block.timestamp);
            tokenLqInfo[tokenAddr].rmLqAmount += lqAmount;
            tokenLqInfo[tokenAddr].isStartLiqWar = true;

            //token
            IERC20(tokenAddr).safeTransfer(DEAD,IERC20(tokenAddr).balanceOf(address(this)));

            if(!flag){
                tokenLqInfo[tokenAddr].isCTOFlag = true;
                lqBalance = IERC20(pair).balanceOf(address(this));
                if(lqBalance > 0){
                    IERC20(pair).safeTransfer(DEAD, lqBalance);
                }
            }

            emit WithdrawDebitForLiqWar(tokenAddr,pair,lqAmount,amountETH,flag);
        }

    }

    function _removeLiqWarLiquidity(uint256 seqNo,address tokenAddr) internal {
        address pair = tokenPair[tokenAddr];
        uint256 lqBalance = IERC20(pair).balanceOf(address(this));
        uint256 lqAmount = lqBalance * rmLiqWarRate / basePoints;

        IERC20(pair).safeApprove(address(swapRouter), lqAmount);
        (, uint amountETH) = swapRouter.removeLiquidityETH(tokenAddr,lqAmount,0,0,address(this), block.timestamp);
        tokenLqInfo[tokenAddr].rmLqAmount += lqAmount;

        //token
        uint256 tokenBalance = IERC20(tokenAddr).balanceOf(address(this));
        IERC20(tokenAddr).safeTransfer(DEAD,tokenBalance);

        //RefundETH
        seqLiqWarInfo[seqNo].rewardETH += amountETH;
        seqLiqWarInfo[seqNo].rmFlag = true;
        emit RemoveLiqWarLiquidity(seqNo,tokenAddr,pair,lqAmount,amountETH);
    }

    //reward two LiqWar token
    function rewardLiqWarToken(uint256 seqNo) public onlyKeeper{
        require(seqLiqWarInfo[seqNo].rmFlag,'Not remove LiqWar');
        require(seqLiqWarInfo[seqNo].rewardSeq < buyTokenCnt,'Not remove LiqWar');
        seqLiqWarInfo[seqNo].rewardSeq++;

        //swap buy
        uint256 buyAmount = seqLiqWarInfo[seqNo].rewardETH / (buyTokenCnt * 2);
        for(uint256 i = 0;i < 2; i++){
            address buyToken = seqLiqWarInfo[seqNo].rewardTokenAddrs[i];
            address[] memory path = new address[](2);
            path[0] = address(WETH);
            path[1] = address(buyToken);
            swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value:buyAmount}(
                0,
                path,
                address(this),
                block.timestamp
            );
            //transfer buyToken
            uint256 buyTokenAmount = IERC20(buyToken).balanceOf(address(this));
            IERC20(buyToken).safeTransfer(DEAD,buyTokenAmount);
        }
    }

    function destroyLeftToken() public onlyKeeper {
        require(block.timestamp > endTime,'Not allow to destroy LeftToken');
        require(mintedToken < mintTokenLimit,'Minted less than Limit');
        require(!isDestroyToken,'Already Destroy');
        //left mint token transfer to dead
        uint256 leftMintAmount = mintTokenLimit - mintedToken;
        IERC20(JUMPToken).safeTransfer(DEAD,leftMintAmount);
        isDestroyToken = true;
    }

    //Avoid  unable to remove liquidity
    //The ownership will transfer to timeLock contract or emergency admin role will be multi-sig
    function setRmLqSlippage(uint256 _rmSlippage) public onlyOwner{
        rmSlippage = _rmSlippage;
        emit SetRmLqSlippage(msg.sender,_rmSlippage);
    }

    //Prevent the lending pool from being drained by malicious lending
    //The ownership will transfer to timeLock contract or emergency admin role will be multi-sig
    function setDebitLimit(uint256 _debitLimit) public onlyOwner{
        debitLimit = _debitLimit;
        emit SetDebitLimit(msg.sender,_debitLimit);
    }

    //Prevent the eth Blockchain network congestion from being drained by malicious lending
    //The ownership will transfer to timeLock contract or emergency admin role will be multi-sig
    function setEmergencyBonusPool(address _bonusPool) public onlyOwner{
        bonusPool = IJUMPBonusPool(_bonusPool);
        emit SetBonusPool(msg.sender,address(bonusPool));
    }

    function getCurrMintPhaseInfo() public view returns(uint256 currPhase,uint256 currRate,uint256 nextPhase,uint256 nextRate,uint256 currETHLimit,uint256 currDepositETH){
       currPhase = rangeIndex;
       currRate = mintRange[currPhase];
       if(rangeIndex + 1 < 20){
           nextPhase = currPhase +1;
       }else{
           nextPhase = 19;
       }
       nextRate =  mintRange[nextPhase];
       currETHLimit = buyRange[currPhase];
       currDepositETH = userDepositTotal;
    }


    function getMintIndexAndAmount(uint256 lastDeposit, uint256 userAmount)  public view returns(uint256 mintTokenAmount,uint256 index,uint256[] memory mintRangeIndex,uint256[] memory mintAmounts){
        mintRangeIndex = new uint256[](20);
        mintAmounts = new uint256[](20);
        uint256 cnt;
        for(uint256 i = rangeIndex;i < 20; i++){
            if(lastDeposit <= buyRange[i] && lastDeposit + userAmount <= buyRange[i]){
                mintRangeIndex[cnt] = i;
                index = i;
                mintAmounts[cnt] = userAmount;
                cnt++;
                mintTokenAmount = userAmount * mintRange[i] /1e18;
                break;
            }else if(lastDeposit <= buyRange[i] && lastDeposit + userAmount >= buyRange[i]){
                //cross multi range;
                mintRangeIndex[cnt] = i;
                index = i;
                mintAmounts[cnt] = buyRange[i] - lastDeposit;
                mintTokenAmount += (buyRange[i] - lastDeposit) * mintRange[i] /1e18;
                cnt++;
                //cycle next range:
                uint256 lastMintAmount = buyRange[i];
                for(uint256 j = i+1; j < 20; j++){
                    if(lastDeposit + userAmount >= buyRange[j]){
                        //add j
                        mintRangeIndex[cnt] = j;
                        index = j;
                        mintAmounts[cnt] = buyRange[j] - lastMintAmount;
                        mintTokenAmount += (buyRange[j] - lastMintAmount) * mintRange[j] /1e18;
                        lastMintAmount =  buyRange[j];
                        cnt++;
                    }else{
                        mintRangeIndex[cnt] = j;
                        index = j;
                        mintAmounts[cnt] = lastDeposit + userAmount - buyRange[j-1];
                        mintTokenAmount += (lastDeposit + userAmount - buyRange[j-1]) * mintRange[j] /1e18;
                        cnt++;
                        break;
                    }
                }
                break;
            }
        }
        // Downsize the array to fit.
        assembly {
            mstore(mintRangeIndex, cnt)
            mstore(mintAmounts, cnt)
        }
    }


    function getDebitTime() public view returns(uint256,uint256){
        return (startTime,endTime);
    }
    function getTokenCirculation() public view returns(uint256 circulation){
        circulation = mintedToken + addLQTokenLimit;
    }

    function getLeftInfo() public view returns(uint256 tokenLQAmount, uint256 realMintTokenAmount,uint256 leftLQAmount, uint256 leftMintAmount,uint256 totalLeft){
       tokenLQAmount = addLQTokenLimit;
       leftLQAmount = 0;

        //left mint token transfer to dead
       realMintTokenAmount = mintedToken;
       leftMintAmount = mintTokenLimit - mintedToken;
       totalLeft = leftLQAmount + leftMintAmount;
    }

    function lockLP(address tokenAddr,uint256 lockAmount) public onlyOwner{
        require(block.timestamp > endTime + protectRefundDuration,'Protect lockLP Duration');
        address pair = tokenPair[tokenAddr];
        uint256 lqBalance = IERC20(pair).balanceOf(address(this));
        if(lqBalance > lockAmount){
            IERC20(pair).safeTransfer(lockLPAddr, lockAmount);
        }
    }

    function lockETH(uint256 lockAmount) public onlyOwner{
        require(block.timestamp > endTime + protectRefundDuration,'Protect lockETH Duration');
        (bool success, ) = lockLPAddr.call{value: lockAmount}("");
        require(success, "lockLPAddr Unable to Withdraw ETH");
    }

    function getLQ(address tokenAddr) public view returns(uint256 ethAmount,uint256 reserveEth,uint256 amountOutETHMin,uint256 lqAmount,uint256 lqBalance){
        address pair = tokenPair[tokenAddr];
        uint256 lqTotal = IERC20(pair).totalSupply();
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
        reserveEth = (address(WETH) > tokenAddr) ? reserve1 : reserve0;
        ethAmount = tokenDebitLevel[tokenAddr];
        amountOutETHMin = (ethAmount +  ethAmount * rmSlippage / basePoints) * (basePoints - rmSlippage) / basePoints;
        lqAmount = (ethAmount +  ethAmount * rmSlippage / basePoints) * lqTotal / reserveEth;
        lqBalance = IERC20(pair).balanceOf(address(this));
    }

    function getCurrBlockAndTime() public view returns(uint256 blockNum,uint256 blockTime){
        blockNum = block.number;
        blockTime = block.timestamp;
    }

    function setKeeper(address addr, bool active) public onlyOwner {
        keeperMap[addr] = active;
        emit SetKeeper(msg.sender,addr,active);
    }
    function isKeeper(address addr) public view returns (bool) {
        return keeperMap[addr];
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
    unchecked {
        uint256 oldAllowance = token.allowance(address(this), spender);
        require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
        uint256 newAllowance = oldAllowance - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    }


    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}