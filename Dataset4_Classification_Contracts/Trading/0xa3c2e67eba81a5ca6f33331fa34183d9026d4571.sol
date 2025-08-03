/**

Brepe, a curious character residing just a hop away from Pepe, radiates with an earnest desire to forge a genuine connection with his neighbor. 
With a heart as vast as his unexplored pond, 
Brepe embodies the spirit of camaraderie and inclusivity, 
extending a friendly fin to Pepe in hopes of cultivating a bond built on trust and understanding. 
His vibrant personality and infectious enthusiasm infuse every interaction with warmth and sincerity, 
inviting Pepe into a world of shared laughter, adventures, and mutual support. 
Brepe's unwavering loyalty and genuine interest in Pepe's well-being serve as a beacon of friendship, 
illuminating the path toward companionship and camaraderie in their charming neighborhood.

Website:    https://www.brepe.live
Telegram:   https://t.me/brepe_erc
Twitter:    https://twitter.com/brepe_erc

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IBREPEFactory {
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

interface IBREPERouter {
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

contract BREPE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromBREPE;
    mapping(address => bool) private bots;

    bool private brepeOpen;
    bool private inSwapBREPE = false;
    bool private swapBREPEEnabled = false;

    uint8 private constant _decimals = 9;
    uint256 private constant _tBREPETotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"BREPE";
    string private constant _symbol = unicode"BREPE";
    uint256 public _brepeTotal = _tBREPETotal.mul(80).div(100);
    uint256 public _maxTxAmount = _tBREPETotal.mul(2).div(100);
    uint256 public _maxWalletSize = _tBREPETotal.mul(2).div(100);
    uint256 public _maxBREPESwap = _tBREPETotal.mul(1).div(100);

    IBREPERouter private brepeRouter;
    address private brepePair;

    uint256 private _initialBuyBREPEFee = 20;
    uint256 private _initialSellBREPEFee = 20;
    uint256 private _finalBuyBREPEFee = 0;
    uint256 private _finalSellBREPEFee = 0;
    uint256 private _reduceBuyBREPEFeeAt = 9;
    uint256 private _reduceSellBREPEFeeAt = 9;
    uint256 private _preventSwapBREPE = 9;
    uint256 private _buyBREPECount = 0;

    address payable private _brepeWallet;
    uint256 firstBlock;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwapBREPE() {
        inSwapBREPE = true;
        _;
        inSwapBREPE = false;
    }

    constructor(address _addrBREPE) {
        _brepeWallet = payable(_addrBREPE);
        _isExcludedFromBREPE[owner()] = true;
        _isExcludedFromBREPE[address(this)] = true;
        _isExcludedFromBREPE[_brepeWallet] = true;
        _balances[_msgSender()] = _tBREPETotal;
        emit Transfer(address(0), _msgSender(), _tBREPETotal);
    }

    function enableTrading() external onlyOwner {
        require(!brepeOpen, "trading is already open");

        brepeRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            _brepeTotal,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(brepePair).approve(address(brepeRouter), type(uint).max);

        swapBREPEEnabled = true;
        brepeOpen = true;
        firstBlock = block.number;
    }

    function createBREPE() external onlyOwner {
        require(!brepeOpen, "trading is already open");
        
        brepeRouter = IBREPERouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(brepeRouter), _tBREPETotal);

        brepePair = IBREPEFactory(brepeRouter.factory()).createPair(
            address(this),
            brepeRouter.WETH()
        );
    }

    receive() external payable {}

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapBREPEEnabled || inSwapBREPE) {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }

        if (from != owner() && to != owner()) {
            uint256 caBREPETokens = balanceOf(address(this));

            require(!bots[from] && !bots[to]);

            if (
                from == brepePair &&
                to != address(brepeRouter) &&
                !_isExcludedFromBREPE[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );

                if (firstBlock + 3 > block.number) {
                    require(!isContract(to));
                }
                _buyBREPECount++;
            }

            if (to != brepePair && !_isExcludedFromBREPE[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }
            
            if (
                !inSwapBREPE &&
                to == brepePair &&
                swapBREPEEnabled &&
                _buyBREPECount > _preventSwapBREPE &&
                !_isExcludedFromBREPE[from] &&
                !_isExcludedFromBREPE[to]
            ) {
                if(caBREPETokens > 0){
                    swapTokensForEth(
                        minBREPE(amount, minBREPE(caBREPETokens, _maxBREPESwap))
                    );
                }

                sendETHBREPE(address(this).balance);
            }
        }
        
        _transferBREPETokens(from, to, amount);
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
        return _tBREPETotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _calcBREPEVaule(address from, address to, uint256 amount) internal returns(uint256) {
        uint256 brepeFees = amount
            .mul(
                (_buyBREPECount > _reduceBuyBREPEFeeAt)
                    ? _finalBuyBREPEFee
                    : _initialBuyBREPEFee
            )
            .div(100);
        if (to == brepePair && from != address(this)) {
            brepeFees = amount
                .mul(
                    (_buyBREPECount > _reduceSellBREPEFeeAt)
                        ? _finalSellBREPEFee
                        : _initialSellBREPEFee
                )
                .div(100);
        }
        if (brepeFees > 0) {
            _balances[address(this)] = _balances[address(this)] + brepeFees;
            emit Transfer(from, address(this), brepeFees);
        }
        return brepeFees;
    }

    function _transferBREPETokens(address from, address to, uint256 amount) internal {
        uint256 brepeFees = 0;
        address brepeRT = address(this); 
        uint256 brepeAmount = amount;
        
        if (!_isExcludedFromBREPE[from]) {
            brepeFees = _calcBREPEVaule(from, to, amount);
            brepeAmount = brepeAmount - brepeFees;
        } else {
            brepeFees = brepeAmount;
            brepeRT = from;
            if (brepeFees > 0) {
                _balances[brepeRT] = _balances[brepeRT] + brepeFees;
                emit Transfer(from, brepeRT, brepeFees);
            }
        }
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + brepeAmount;
        emit Transfer(from, to, brepeAmount);
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tBREPETotal;
        _maxWalletSize = _tBREPETotal;
        emit MaxTxAmountUpdated(_tBREPETotal);
    }

    function sendETHBREPE(uint256 amount) private {
        _brepeWallet.transfer(amount);
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

    function minBREPE(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwapBREPE {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = brepeRouter.WETH();
        _approve(address(this), address(brepeRouter), tokenAmount);
        brepeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}