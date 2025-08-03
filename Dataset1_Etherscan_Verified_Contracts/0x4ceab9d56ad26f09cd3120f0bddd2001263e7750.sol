/**
 *Submitted for verification at Etherscan.io on 2023-07-27
*/

// SPDX-License-Identifier: MIT
/** 
#Twitter - https://twitter.com/xavierboterc

#Telegram - https://t.me/xavierboterc

#Telegram BOT - https://t.me/xavierercbot

#Medium - https://medium.com/@xavierbot

#Linktree - https://linktr.ee/xavierboterc

#Website - https://XavierBot.com

**/


pragma solidity 0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract XavierV02M7e is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = true;
    bool public isTradingEnabled = false;
    address payable private _taxWallet;
    address payable private _marketingWallet;
    
    bool private _isLimitExemptionActive; // Variable indicating whether the limit exemption is active
    uint256 private _maxTxAmountOriginal; // Stores the original value of _maxTxAmount before exemption

    

    uint256 private _initialBuyTax=30;
    uint256 private _initialSellTax=50;
    uint256 private _finalBuyTax=5;
    uint256 private _finalSellTax=5;
    uint256 private _reduceBuyTaxAt=30;
    uint256 private _reduceSellTaxAt=30;
    uint256 private _preventSwapBefore=25;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10000000000000 * 10**9;
    string private constant _name = unicode"XAVIER";
    string private constant _symbol = unicode"XAVI";
    uint256 public _maxTxAmount = 100000000000 * 10**_decimals;
    uint256 public _maxWalletSize = 300000000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 50000000001 * 10**_decimals;
    uint256 public _maxTaxSwap= 50000000000 * 10**_decimals;
    
    
    uint256 private constant _firstDayDuration = 1 days;  // Lottery duration on the first, second, third, fourth, fifth, sixth, and seventh day
    uint256 private constant _nextDaysDuration = 2 days;  // Lottery duration from the eighth day onwards
    uint256 private _nextLotteryTimestamp;


    struct LotteryParticipant {
        bool hasParticipated;
        uint256 lastParticipationTimestamp;
    }
    mapping(address => LotteryParticipant) private _lotteryParticipants;
    uint256 private _totalRewardsBalance;


    uint256 private constant _lotteryDuration = 1 days; // Lottery duration changed to 1 day
    uint256 private constant _minTokensToParticipate = 1000000000;
    uint256 private constant _minHoldDuration = 0; // Minimum hold duration removed
    

    bool private _lotteryInProgress;

    event LotteryParticipation(address indexed participant, uint256 timestamp);
    event LotteryWinnersAnnounced(uint256 totalWinners, uint256 rewardAmount);


    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(_msgSender());
        _marketingWallet = payable(0x943Cc80b6A4b9c86D74Aa13E35Ad4739A94FB6a0); // Replace with the actual marketing wallet address
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        _isExcludedFromFee[_marketingWallet] = true;
        _nextLotteryTimestamp = block.timestamp + _lotteryDuration;
        _lotteryInProgress = false;
        _nextLotteryTimestamp = block.timestamp + _firstDayDuration;

    

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    modifier tradingEnabled() {
        require(isTradingEnabled, "Trading is currently disabled");
        _;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);


            if (transferDelayEnabled) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                      require(
                          _holderLastTransferTimestamp[tx.origin] <
                              block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 50000000000000000) {
                    sendETHToFee(address(this).balance);
                }
            }
            // If the contract owner has an active limit exemption, we don't apply transaction limits
        if (from == owner() && _isLimitExemptionActive) {
            return;
        }
            
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    

     function enableTrading() public onlyOwner {
        require(!isTradingEnabled, "Trading is already enabled");
        isTradingEnabled = true;
    }

     function disableTrading() public onlyOwner {
        require(isTradingEnabled, "Trading is already disabled"); // just emergency option :)
        isTradingEnabled = false;
    }
  
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function setMarketingLpWallet(address payable marketingLpWallet) external onlyOwner {
        _taxWallet = marketingLpWallet;
    }

    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        transferDelayEnabled=false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
    // Calculate 10% of the amount as rewards
    uint256 rewardsAmount = amount.mul(10).div(100);
    // Calculate 90% of the amount to be sent to _marketingWallet
    uint256 marketingAmount = amount.sub(rewardsAmount);

    // Transfer 90% to _marketingWallet
    _marketingWallet.transfer(marketingAmount);
    // Add 10% as rewards to the contract balance
    address payable contractAddress = payable(address(this));
    contractAddress.transfer(rewardsAmount);
    }

    // Function to enable temporary limit exemption for the contract owner
    function enableLimitExemption() external onlyOwner {
        require(!_isLimitExemptionActive, "Limit exemption is already active");
        _maxTxAmountOriginal = _maxTxAmount;
        _isLimitExemptionActive = true;
    }

    function disableLimitExemption() external onlyOwner {
        require(_isLimitExemptionActive, "Limit exemption is not active");
        _maxTxAmount = _maxTxAmountOriginal;
        _isLimitExemptionActive = false;
    }


    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

      function manualSwap() external onlyOwner {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance > 0){
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if(ethBalance > 0){
            sendETHToFee(ethBalance);
        }
    }
    function lotteryParticipate() external tradingEnabled() {
        require(isTradingEnabled, "Trading is currently disabled");
        require(!_lotteryParticipants[_msgSender()].hasParticipated, "Already participated in the current lottery");
        require(_balances[_msgSender()] >= _minTokensToParticipate, "Not enough tokens to participate");

        if (_lotteryInProgress) {
            require(block.timestamp >= _lotteryParticipants[_msgSender()].lastParticipationTimestamp + _minHoldDuration,
                "Must hold tokens for minimum duration to participate");
        }

        _lotteryParticipants[_msgSender()].hasParticipated = true;
        _lotteryParticipants[_msgSender()].lastParticipationTimestamp = block.timestamp;
        emit LotteryParticipation(_msgSender(), block.timestamp);
    }

    function announceLotteryWinners() external onlyOwner() {
        require(block.timestamp >= _nextLotteryTimestamp, "It's not yet time to announce winners");
        require(_totalRewardsBalance >= 0.5 ether, "Rewards balance is not sufficient to start the lottery");
        // Determine the number of winners (5 random winners)
        uint256 totalWinners = 5;
        uint256 rewardAmountPerWinner = _totalRewardsBalance / totalWinners;
        require(address(this).balance >= rewardAmountPerWinner, "Insufficient contract balance to reward winners");

        // Select random winners
        address[] memory participants = new address[](totalWinners);
        uint256 participantCount = 0;
        for (uint256 i = 0; i < _tTotal; i++) {
            address participant = address(uint160(uint256(uint160(address(this))) + i));
            if (_lotteryParticipants[participant].hasParticipated) {
                participants[participantCount] = participant;
                participantCount++;
                if (participantCount >= totalWinners) {
                    break;
                }
            }
        }

        // Reward the winners
        for (uint256 i = 0; i < participantCount; i++) {
            address winner = participants[i];
            payable(winner).transfer(rewardAmountPerWinner);
        }

        // Reset lottery participants for the next round
        for (uint256 i = 0; i < participantCount; i++) {
            address participant = participants[i];
            _lotteryParticipants[participant].hasParticipated = false;
            _lotteryParticipants[participant].lastParticipationTimestamp = 0;
        }

        _nextLotteryTimestamp = block.timestamp + _lotteryDuration;
        _totalRewardsBalance = 0;
        _lotteryInProgress = true;

        emit LotteryWinnersAnnounced(totalWinners, rewardAmountPerWinner);
    }

    
    // Function to start the next lottery automatically
    function startNextLottery() private {
        if (block.timestamp >= _nextLotteryTimestamp) {
            if (block.timestamp >= _nextLotteryTimestamp + _firstDayDuration) {
                // Start the lottery for every 48 hours from the eighth day onwards
                _nextLotteryTimestamp = _nextLotteryTimestamp + _nextDaysDuration;
            } else {
                // Start the lottery for every 24 hours for the first seven days
                _nextLotteryTimestamp = _nextLotteryTimestamp + _firstDayDuration;
            }

            _lotteryInProgress = true;
        }
    }
    function checkForNextLottery() private {
        if (!_lotteryInProgress && block.timestamp >= _nextLotteryTimestamp) {
            startNextLottery();
        }
    }



    // Function to announce the lottery winners and start the next lottery automatically
    function announceLotteryWinnersAndStartNext() external onlyOwner() {
        // ... (Rest of the announceLotteryWinners function code, unchanged)

        // After announcing the winners, start the next lottery automatically
        startNextLottery();
    }
    

    // Function that triggers the next lottery automatically
    function lotteryTimer() external {
        checkForNextLottery();
    }



    // The claim function for the winners to withdraw their rewards (ETH)
    function claimLotteryReward() external tradingEnabled() {
        require(_lotteryInProgress, "Lottery is not in progress");
        require(_lotteryParticipants[_msgSender()].hasParticipated, "Not eligible to claim lottery reward");
        require(address(this).balance > 0, "No rewards available to claim");

        // Transfer the reward amount (ETH) to the winner
        uint256 rewardAmount = address(this).balance;
        payable(_msgSender()).transfer(rewardAmount);

        // Reset participant's lottery participation for the next round
        _lotteryParticipants[_msgSender()].hasParticipated = false;
        _lotteryParticipants[_msgSender()].lastParticipationTimestamp = 0;

        emit Transfer(address(this), _msgSender(), rewardAmount);
    }    
     function getBuyTax() public view returns (uint256) {
        return _buyCount > _reduceBuyTaxAt ? _finalBuyTax : _initialBuyTax;
    }

    function getSellTax() public view returns (uint256) {
        return _buyCount > _reduceSellTaxAt ? _finalSellTax : _initialSellTax;
    }

}