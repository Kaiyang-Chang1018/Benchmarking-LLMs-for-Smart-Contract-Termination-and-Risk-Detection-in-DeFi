/*
 *
 * ██╗███╗░░██╗███████╗██╗███╗░░██╗██╗████████╗███████╗  ███╗░░░███╗░█████╗░███╗░░██╗███████╗██╗░░░██╗
 * ██║████╗░██║██╔════╝██║████╗░██║██║╚══██╔══╝██╔════╝  ████╗░████║██╔══██╗████╗░██║██╔════╝╚██╗░██╔╝
 * ██║██╔██╗██║█████╗░░██║██╔██╗██║██║░░░██║░░░█████╗░░  ██╔████╔██║██║░░██║██╔██╗██║█████╗░░░╚████╔╝░
 * ██║██║╚████║██╔══╝░░██║██║╚████║██║░░░██║░░░██╔══╝░░  ██║╚██╔╝██║██║░░██║██║╚████║██╔══╝░░░░╚██╔╝░░
 * ██║██║░╚███║██║░░░░░██║██║░╚███║██║░░░██║░░░███████╗  ██║░╚═╝░██║╚█████╔╝██║░╚███║███████╗░░░██║░░░
 * ╚═╝╚═╝░░╚══╝╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚══════╝  ╚═╝░░░░░╚═╝░╚════╝░╚═╝░░╚══╝╚══════╝░░░╚═╝░░░
 * ░██████╗░██╗░░░░░██╗████████╗░█████╗░██╗░░██╗
 * ██╔════╝░██║░░░░░██║╚══██╔══╝██╔══██╗██║░░██║
 * ██║░░██╗░██║░░░░░██║░░░██║░░░██║░░╚═╝███████║
 * ██║░░╚██╗██║░░░░░██║░░░██║░░░██║░░██╗██╔══██║
 * ╚██████╔╝███████╗██║░░░██║░░░╚█████╔╝██║░░██║
 * ░╚═════╝░╚══════╝╚═╝░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝
 * Description: Infinite Money Glitch ($IMG) Official Token Contract
 *
 * Telegram: https://t.me/TheInfiniteMoneyGlitch
 * Twitter: https://x.com/MoneyGlitchERC
 * Website: https://www.theglitch.money
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any _account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

}

interface IREWARD {
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
}

interface IRouter{
    function WETH() external pure returns (address);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external payable;
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

abstract contract ReentrancyGuard {
    
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

contract IMG_DIVIDEND is IREWARD, ReentrancyGuard, Ownable {   
    
    using SafeMath for uint256;

    address public _token;
    IRouter public router;

    address[7] public _rewardTokens;
    address private WETH;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
        uint256 reserved;
    }
    mapping (address => Share) public shares;
    
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public totalReserved;

    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    // user -> token -> Amount
    mapping (address => mapping (address => uint256)) public userRewardRecord;
    mapping (address => uint256) public tokenPayouts;

    bool public ActivateDividend;

    modifier onlyToken() {
        require(msg.sender == _token); 
        _;
    }

    event rewardTransferred(address _tokenAddress, uint256 _tokenAmount, uint256 _ethValue, uint256 _timestamp);

    constructor() {
        router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        WETH = router.WETH();
        initalizeTokens();
    }

    function initalizeTokens() internal {
        _rewardTokens[0] = address(0x6982508145454Ce325dDbE47a25d4ec3d2311933);  // PEPE
        _rewardTokens[1] = address(0x812Ba41e071C7b7fA4EBcFB62dF5F45f6fA853Ee);  // NEIRO
        _rewardTokens[2] = address(0xE0f63A424a4439cBE457D80E4f4b51aD25b2c56C);  // SPX
        _rewardTokens[3] = address(0xaaeE1A9723aaDB7afA2810263653A34bA2C21C7a);  // MOG
        _rewardTokens[4] = address(0xB90B2A35C65dBC466b04240097Ca756ad2005295);  // BOBO
        _rewardTokens[5] = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);  // WETH
        _rewardTokens[6] = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);  // USDC
    }

    function updateRewardTokens(uint _pid, address _rewardToken) external onlyOwner {
        _rewardTokens[_pid] = address(_rewardToken);
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(!ActivateDividend) return;
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 amount = msg.value;
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }
        uint256 amount = calEarning(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            shares[shareholder].reserved += amount;
            totalReserved += amount;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function getUnpaidEarning(address shareholder) public view returns (uint256) {
        uint calReward = calEarning(shareholder);
        uint reservedReward = shares[shareholder].reserved;
        return calReward.add(reservedReward);
    }

    function setToken(address _tk) external onlyOwner {
        _token = _tk;
    }

    function setRouter(address _newRouter) external onlyOwner {
        router = IRouter(_newRouter);
    }

    function claimChoice(uint256[7] memory _percentage) external nonReentrant() {
        uint sumTotal = _percentage[0].add(_percentage[1]).add(_percentage[2]).add(_percentage[3]).add(_percentage[4]).add(_percentage[5]).add(_percentage[6]);
        require(sumTotal == 100, 'Sum MisMatch!');

        address user = msg.sender;
        distributeDividend(user);
        uint subtotal = shares[user].reserved;

        if(subtotal > 0) {
            shares[user].reserved = 0;
            totalReserved = totalReserved.sub(subtotal);
            for(uint i = 0; i < _percentage.length; i++) {
                uint buyvalue = subtotal.mul(_percentage[i]).div(100);
                if(buyvalue == 0) continue;
                if(_rewardTokens[i] != address(WETH)) {
                    address[] memory path = new address[](2);
                    path[0] = router.WETH();
                    path[1] = address(_rewardTokens[i]);
                    uint256 initialBalance = IERC20(_rewardTokens[i]).balanceOf(user);
                    router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: buyvalue}(
                        0,
                        path,
                        address(user),
                        block.timestamp
                    );
                    uint256 recievedBalance = IERC20(_rewardTokens[i]).balanceOf(user).sub(initialBalance);
                    userRewardRecord[user][_rewardTokens[i]] += recievedBalance;
                    tokenPayouts[_rewardTokens[i]] += recievedBalance;
                    emit rewardTransferred(_rewardTokens[i], recievedBalance, buyvalue, block.timestamp);
                }
                else {
                    payable(user).transfer(buyvalue);
                    userRewardRecord[user][_rewardTokens[i]] += buyvalue;
                    tokenPayouts[_rewardTokens[i]] += buyvalue;
                    emit rewardTransferred(_rewardTokens[i], buyvalue, buyvalue, block.timestamp);
                }
            }
        }

    }

    function calEarning(address shareholder) internal view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    receive() external payable {}

    function enableDividend() external onlyOwner {
        require(!ActivateDividend,'404');
        ActivateDividend = true;
    }

    function rescueFunds() external onlyOwner { 
        (bool os,) = payable(msg.sender).call{value: address(this).balance}("");
        require(os,"Transaction Failed!!");
    }

    function rescueTokens(address _tokenAddress,address recipient,uint _amount) external onlyOwner {
        (bool success, ) = address(_tokenAddress).call(abi.encodeWithSignature('transfer(address,uint256)',  recipient, _amount));
        require(success, 'Token payment failed');
    }

}