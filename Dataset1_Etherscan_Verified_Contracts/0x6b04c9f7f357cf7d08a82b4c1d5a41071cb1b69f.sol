// SPDX-License-Identifier: UNLICENSE

    pragma solidity 0.8.23;

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

    contract TestWillRug3 is Context, IERC20, Ownable {
        using SafeMath for uint256;
        mapping (address => uint256) private _balances;
        mapping (address => mapping (address => uint256)) private _allowances;
        mapping(address => uint256) public lastTransferTimestamp;
        mapping (address => bool) public _isExcludedFromFee;
        mapping (address => bool) private blacklisted;
        mapping(address => uint256) private _lastBuy;
        mapping(address => uint256) private _lastSell;


   
        address payable private marketingWallet;
        address private treasuryWallet;
        address private airdropWallet;

        uint256 private initialBuyTax = 19; // 19% initial buy tax
        uint256 private initialSellTax = 33; // 33% initial sell tax
        uint256 private penaltyPercentage = 33; // 50% penalty by default
        uint256 private taxPercentage = 10; // 10% goes to tax
        uint256 private burnPercentage = 90; // 90% goes to burn


        address public constant DEAD = 0x000000000000000000000000000000000000dEaD;  // 0x00000000000000000000000000000000
        uint8 private constant _decimals = 18;
        uint256 private constant _tTotal = 1000000 * 10**_decimals;
        string private constant _name = unicode"TestWillRug3";
        string private constant _symbol = unicode"TestWillRug3";
        uint256 public _maxTxAmount = _tTotal.mul(20).div(1000);
        uint256 public _maxWalletSize = _tTotal.mul(20).div(1000);
        uint256 public _taxSwapThreshold= _tTotal.mul(5).div(1000);
        uint256 public sellRestrictionTime = 3600;  // Default to 1 hour 
        uint256 public _maxTaxSwap= _tTotal.mul(10).div(1000);

        IUniswapV2Router02 private uniswapV2Router;
        address private uniswapV2Pair;
        bool private tradingOpen;
        bool public initialLaunchPeriod = true;
        bool private inSwap = false;
        bool private swapEnabled = false;

        event Burn(address indexed from, uint256 value);
        modifier lockTheSwap {
            inSwap = true;
            _;
            inSwap = false;
        }

        constructor(
           address _router,
        address payable _marketingWallet,
        address _treasuryWallet,
        address _airdropWallet
        )  {
        

        marketingWallet = _marketingWallet;
        treasuryWallet = _treasuryWallet;
        airdropWallet = _airdropWallet;

         uint256 marketingAmount = _tTotal.mul(5).div(100);  // 5%
        uint256 treasuryAmount = _tTotal.mul(5).div(100);   // 5%
        uint256 airdropAmount = _tTotal.mul(3).div(100);    // 3%
        uint256 remainingAmount = _tTotal.sub(marketingAmount).sub(treasuryAmount).sub(airdropAmount);


         _balances[_msgSender()] = remainingAmount;
        _balances[marketingWallet] = marketingAmount;
        _balances[treasuryWallet] = treasuryAmount;
        _balances[airdropWallet] = airdropAmount;


        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[treasuryWallet] = true;
        _isExcludedFromFee[airdropWallet] = true;


            uniswapV2Router = IUniswapV2Router02(_router);
            uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
                .createPair(address(this), uniswapV2Router.WETH());

        emit Transfer(address(0), _msgSender(), remainingAmount);
        emit Transfer(address(0), marketingWallet, marketingAmount);
        emit Transfer(address(0), treasuryWallet, treasuryAmount);
        emit Transfer(address(0), airdropWallet, airdropAmount);
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

    function whitelistAddress(address account, bool exempt) external onlyOwner {
        _isExcludedFromFee[account] = exempt;
    }
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(!blacklisted[sender] && !blacklisted[recipient], "Blacklisted address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (!tradingOpen && (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient])) {
                _balances[sender]=_balances[sender].sub(amount);
            _balances[recipient]=_balances[recipient].add(amount);
                emit Transfer(sender, recipient, amount);
            return;
        }

        if (sender == uniswapV2Pair && recipient != address(uniswapV2Router) && ! _isExcludedFromFee[recipient] )
        {
            require(amount <= _maxTxAmount, "Exceeds max transaction limit");
            require(balanceOf(recipient).add(amount) <= _maxWalletSize, "Exceeds max wallet limit");
        }
        else if (sender != uniswapV2Pair && recipient != uniswapV2Pair && sender != address(uniswapV2Router) && recipient != address(uniswapV2Router)  && ! _isExcludedFromFee[recipient] )
        {
            // This is a wallet-to-wallet transfer
            require(amount <= _maxTxAmount, "Exceeds max transaction limit");
            require(balanceOf(recipient).add(amount) <= _maxWalletSize, "Exceeds max wallet limit");
        }

        require(tradingOpen,  "Trading must be open");

        uint256 penaltyAmount = 0;
        uint256 taxAmount = 0;

        // Only apply penalties and restrictions after the initial launch period
        if (!initialLaunchPeriod) {
            // Enforce the 1-hour restriction after a transfer
            if (recipient == uniswapV2Pair && !_isExcludedFromFee[sender]) {  // Sell action
            
                // Check for sell rule violations:
                bool ruleViolated = false;

                // Condition 1: Cannot sell within 1 hour of last buy
                if (block.timestamp.sub(_lastBuy[sender]) < sellRestrictionTime) {
                    ruleViolated = true;
                }

                // Condition 2: Cannot sell more than 20% of the bag
                if (amount > balanceOf(sender).mul(20).div(100)) {
                    ruleViolated = true;
                }

                // Condition 3: Cannot sell more than once per hour
                if (block.timestamp.sub(_lastSell[sender]) < sellRestrictionTime) {
                    ruleViolated = true;
                }

                // If any rules are violated, apply penalty
                if (ruleViolated) {
                    penaltyAmount = amount.mul(penaltyPercentage).div(100);  // Apply penalty based on rule violations
                    uint256 burnAmount = penaltyAmount.mul(burnPercentage).div(100);
                    taxAmount = penaltyAmount.mul(taxPercentage).div(100); // Set taxAmount based on penalty
                    
                    // Burn the penalty tokens
                    _burn(sender, burnAmount);
                }
            }
        }
        else{
            // Apply the initial buy tax
            if (sender == uniswapV2Pair && !_isExcludedFromFee[recipient]) { // Buy action
                taxAmount = amount.mul(initialBuyTax).div(100);
            }

            // Apply the initial sell tax
            if (recipient == uniswapV2Pair && !_isExcludedFromFee[sender]) { // Sell action
                taxAmount = amount.mul(initialSellTax).div(100);
            }
        }

    
        uint256 contractTokenBalance = balanceOf(address(this));
        // Transfer the total fee (including tax from penalty if applicable) once
        if (taxAmount > 0 && recipient == uniswapV2Pair  && contractTokenBalance>_taxSwapThreshold) {

            swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
            uint256 contractETHBalance = address(this).balance;
            if (contractETHBalance > 0) {
                sendETHToFee(address(this).balance);
            }

            }

            if (taxAmount >0){
                _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(sender, address(this),taxAmount);
            }

            _balances[sender]=_balances[sender].sub(amount);
                
                if(penaltyAmount > 0)
                {
                    _balances[recipient]=_balances[recipient].add(amount.sub(penaltyAmount));
                    emit Transfer(sender, recipient, amount.sub(penaltyAmount));

                }
                else{
                    
                    _balances[recipient]=_balances[recipient].add(amount.sub(taxAmount));
                    emit Transfer(sender, recipient, amount.sub(taxAmount));

                }

                if (recipient == uniswapV2Pair) {
                    _lastSell[sender] = block.timestamp;  // Update last sell time
                } else
                     {
                    _lastBuy[recipient] = block.timestamp;  // Update last buy time
                }
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

        function removeLimits () external onlyOwner {
            initialLaunchPeriod = false;
        }

    

        function sendETHToFee(uint256 amount) private {
            marketingWallet.transfer(amount);
        }
        function updatePenaltyRates(uint256 _penaltyPercentage, uint256 _taxPercentage, uint256 _burnPercentage) external onlyOwner {
            require(_penaltyPercentage <= 100, "Penalty cannot be more than 100%");
            require(_taxPercentage + _burnPercentage == 100, "Tax and burn must total 100%");
            penaltyPercentage = _penaltyPercentage;
            taxPercentage = _taxPercentage;
            burnPercentage = _burnPercentage;
        }
        function addBot(address[] memory blacklisted_) public onlyOwner {
            for (uint i = 0; i < blacklisted_.length; i++) {
                blacklisted[blacklisted_[i]] = true;
            }
        }

        function delBot(address[] memory notbot) public onlyOwner {
        for (uint i = 0; i < notbot.length; i++) {
            blacklisted[notbot[i]] = false;
        }
        }

        function isBot(address a) public view returns (bool){
        return blacklisted[a];
        }

        function openTrading() external onlyOwner() {
            require(!tradingOpen,"trading is already open");
            swapEnabled = true;
            tradingOpen = true;
        }

        
        function reduceFee(uint256 _newBuyFee, uint256 _newSellFee) external onlyOwner() {
        
        require(_newBuyFee<=50 && _newSellFee<=50);
        initialBuyTax=_newBuyFee;
        initialSellTax=_newSellFee;
        }

        receive() external payable {}

        function rescueERC20(address _address, uint256 percent) external onlyOwner() {
            
            uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
            IERC20(_address).transfer(marketingWallet, _amount);
        }

        function manualSwap() external onlyOwner()  {
            
            uint256 tokenBalance=balanceOf(address(this));
            if(tokenBalance>0 && swapEnabled){
            swapTokensForEth(tokenBalance);
            }
            uint256 ethBalance=address(this).balance;
            if(ethBalance>0){
            sendETHToFee(ethBalance);
            }
        }

    function _burn(address account, uint256 amount) private {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _balances[DEAD] = _balances[DEAD].add(amount);  // Update DEAD address balance
        emit Burn(account, amount);
        emit Transfer(account, DEAD, amount);
    }
    function updateSellRestrictionTime(uint256 _sellRestrictionTime) external onlyOwner {
        sellRestrictionTime = _sellRestrictionTime;
    }
    }