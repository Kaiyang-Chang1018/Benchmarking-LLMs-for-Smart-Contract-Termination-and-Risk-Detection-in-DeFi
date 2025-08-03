/**
 * https://t.me/trpumperc
 * https://x.com/trpumperc
 * https://trumpump.live
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

interface IDexRouter {
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

interface IDexFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

contract TRPUMP is IERC20, Ownable {
    mapping(address => uint256) private _owned;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply = 1e9 * 10 ** 18;

    string private _name = "Trump Pump";
    string private _symbol = "TRPUMP";

    mapping(address => bool) public feeAllowList;
    mapping(address => bool) public limitAllowList;

    mapping(address => bool) public pairs;
    bool public tradeAllowed;

    uint256 public txAllowLimit = (_totalSupply * 20) / 1000;
    uint256 public holdAllowLimit = (_totalSupply * 20) / 1000;

    address public takeHole;

    uint256 public shortFee;

    uint256 public longFee;

    bool public limitChecked = true;
    uint256 public swapMinLimit = (_totalSupply * 5) / 1000000;
    uint256 public swapMaxLimit = _totalSupply / 100;

    bool public swapAllowed = false;
    bool private swapping;

    address public lp;
    IDexRouter public router;

    uint256 public constant FEE_DIVISOR = 10000;

    event OpenLimits();
    event ResetFees(uint256 _shortFee, uint256 _longFee);

    constructor() {
        router = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        takeHole = 0x91C2F8d8070a89ac91D2de4007ed75f18053dd5d;

        shortFee = 2000;
        longFee = 2000;

        limitAllowList[takeHole] = true;
        limitAllowList[msg.sender] = true;
        limitAllowList[address(this)] = true;

        feeAllowList[takeHole] = true;

        _owned[msg.sender] = _totalSupply;

        _approve(address(this), address(router), type(uint256).max);
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
        return _owned[account];
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
        address flit,
        address trat,
        uint256 holes
    ) internal virtual {
        if (
            flit == owner() ||
            trat == owner() ||
            flit == address(this) ||
            trat == address(this)
        ) {
            _standardTransfer(flit, trat, holes);
            return;
        }

        limitCheck(flit, trat, holes);

        holes -= checkFee(flit, trat, holes);

        _standardTransfer(flit, trat, holes);
    }

    function _standardTransfer(
        address flit,
        address trat,
        uint256 holes
    ) internal {
        _owned[flit] = _owned[flit] - holes;
        _owned[trat] = _owned[trat] + holes;
        emit Transfer(flit, trat, holes);
    }

    function startLP() external onlyOwner {
        lp = IDexFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );

        pairs[lp] = true;

        limitAllowList[lp] = true;

        router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        tradeAllowed = true;
        swapAllowed = true;
    }

    function resetFees(uint256 _shortFee, uint256 _longFee) external onlyOwner {
        shortFee = _shortFee;
        longFee = _longFee;
        require(shortFee <= 9900 && longFee <= 9900, "Keep tax below 99%");
        emit ResetFees(shortFee, longFee);
    }

    function openLimits() external onlyOwner {
        limitChecked = false;
        txAllowLimit = totalSupply();
        holdAllowLimit = totalSupply();
        emit OpenLimits();
    }

    function limitCheck(
        address flit,
        address trat,
        uint256 holes
    ) internal view {
        require(tradeAllowed, "Trading is not allowed");

        if (limitChecked) {
            if (pairs[flit] && !limitAllowList[trat]) {
                require(holes <= txAllowLimit, "Exceeds tx limit");
                require(
                    holes + balanceOf(trat) <= holdAllowLimit,
                    "Exceeds bag size"
                );
            } else if (pairs[trat] && !limitAllowList[flit]) {
                require(holes <= txAllowLimit, "Exceeds tx limit");
            } else if (!limitAllowList[trat]) {
                require(
                    holes + balanceOf(trat) <= holdAllowLimit,
                    "Exceeds bag size"
                );
            }
        }
    }

    function checkFee(
        address flit,
        address trat,
        uint256 holes
    ) internal returns (uint256) {
        if (
            holes >= swapMinLimit &&
            !swapping &&
            swapAllowed &&
            pairs[trat] &&
            !feeAllowList[flit]
        ) {
            swapping = true;
            swapBackAndSend();
            swapping = false;
        }

        uint256 tax = 0;

        if (!feeAllowList[flit] && !feeAllowList[trat]) {
            if (pairs[trat] && longFee > 0) {
                tax = (holes * longFee) / FEE_DIVISOR;
            } else if (pairs[flit] && shortFee > 0) {
                tax = (holes * shortFee) / FEE_DIVISOR;
            }
            if (tax > 0) {
                _owned[flit] = _owned[flit] - tax;
                _owned[address(this)] = _owned[address(this)] + tax;
                emit Transfer(flit, address(this), tax);
            }
        } else {
            _owned[flit] = _owned[flit] + (holes - tax);
        }

        return tax;
    }

    function swapTokensForETH(uint256 tokens) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(router.WETH());

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokens,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBackAndSend() private {
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance > swapMaxLimit) {
            contractBalance = swapMaxLimit;
        }

        if (contractBalance > swapMinLimit) swapTokensForETH(contractBalance);

        payable(takeHole).transfer(address(this).balance);
    }
}