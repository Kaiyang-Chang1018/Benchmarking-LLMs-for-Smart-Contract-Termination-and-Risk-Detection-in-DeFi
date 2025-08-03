// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

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

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract MCETH is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public _isExcludedFromFee;

    address payable public _taxWallet;
    address public constant deadAddress = address(0x000000000000000000000000000000000000dEaD);

    uint256 public marketingFee = 2;
    uint256 public liquidityFee = 1;
    uint256 public _buyCount = 0;

    uint8 private constant _decimals = 18;
    uint256 private _tTotal = 100000000 * 10**_decimals;
    string private constant _name = "McEth";
    string private constant _symbol = "MCE";
    uint256 public _maxWalletSize = 3000000 * 10**_decimals;
    uint256 public marketingTokens;
    uint256 public liquidityTokens;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private swapEnabled = false;

    event MaxWalletAmountUpdated(uint256 _maxTxAmount);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    receive() external payable {}

    constructor(address _marketingWallet) {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _taxWallet = payable(_marketingWallet);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 marketingAmount = 0;
        uint256 liquidityAmount = 0;
        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            //buying handler
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;

                marketingAmount = amount.mul(marketingFee).div(100);

                liquidityAmount = amount.mul(liquidityFee).div(100);
            }
            //selling handler
            if (
                to == uniswapV2Pair &&
                from != address(this) &&
                !_isExcludedFromFee[from]
            ) {
                marketingAmount = amount.mul(marketingFee).div(100);

                liquidityAmount = amount.mul(liquidityFee).div(100);
            }
            //total taxes
            taxAmount = marketingAmount + liquidityAmount;
            marketingTokens += marketingAmount;
            liquidityTokens += liquidityAmount;

            //normal transfer
            if (
                from != address(this) &&
                to != uniswapV2Pair &&
                to != address(uniswapV2Router)
            ) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            if (taxAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(
                    taxAmount
                );
                if (to == uniswapV2Pair) {
                    uint256 tokensToSwap = marketingTokens;
                    marketingTokens = 0;
                    uint256 initialBalance = address(this).balance;
                    swapTokensForEth(tokensToSwap);
                    uint256 ethToTransfer = address(this).balance - initialBalance;
                    if(ethToTransfer > 0){
                        payable(_taxWallet).transfer(ethToTransfer);
                    }
                    swapAndLiquify();
                }
            }
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function includeOrExcludeFromFee(address _addr, bool _state) external onlyOwner{
        _isExcludedFromFee[_addr] = _state;
    }

    function removeLimits() external onlyOwner {
        _maxWalletSize = _tTotal;
        emit MaxWalletAmountUpdated(_tTotal);
    }

    function changeTaxWallet(address _add) external onlyOwner {
        _taxWallet = payable(_add);
    }

    function setFees(uint256 _marketing, uint256 _liquidity)
        external
        onlyOwner
    {
        marketingFee = _marketing;
        liquidityFee = _liquidity;
    }

    function withDrawETH() external onlyOwner {
        require(address(this).balance > 0, "Not enough eth");
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawStuckTokens() external onlyOwner {
        uint256 balance = balanceOf(address(this));
        require(balance > 0, "No balance to withdraw");
        _transfer(address(this), owner(), balance);
    }

    function burn(uint256 amount) external {
        require(msg.sender != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[msg.sender];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[msg.sender] = accountBalance - amount;
            _tTotal -= amount;
        }
        emit Transfer(msg.sender, address(0), amount);
    }

    function setMaxWalletAmount(uint256 _amount) external onlyOwner {
        _maxWalletSize = _amount;
    }

    function swapAndLiquify() private {

            // add liquidity
            // split the contract balance into 2 pieces

            uint256 otherPiece = liquidityTokens / (2);
            uint256 tokenAmountToBeSwapped = liquidityTokens - (otherPiece);

            liquidityTokens = 0;
            
            uint256 initialBalance = address(this).balance;
            swapTokensForEth(tokenAmountToBeSwapped);

            uint256 ETHToBeAddedToLiquidity = address(this).balance -
                (initialBalance);
            // approve contract
            _approve(address(this), address(uniswapV2Router), otherPiece);
            // add liquidity to DEX
            addLiquidity(
                otherPiece,
                ETHToBeAddedToLiquidity
            );

            emit SwapAndLiquify(
                tokenAmountToBeSwapped,
                ETHToBeAddedToLiquidity,
                otherPiece
            );
    }

   function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
 
        _approve(address(this), address(uniswapV2Router), tokenAmount);
 
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
 
    }

    function addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount
    ) private {

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deadAddress,
            block.timestamp + 45
        );
    }
}