/**
 * https://t.me/rockfrog
 * https://rockfrog.art
 * https://x.com/rockfrogx
 */


// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.19;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ROCKFROG is IERC20, Ownable {
    using SafeMath for uint256;

    string constant _name = "Rock Frog";
    string constant _symbol = "ROCKFROG";
    uint8 constant _decimals = 18;

    address routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address public autoLiquidityReceiver;
    address public marketingWallet;

    uint256 _totalSupply = 1_000_000_000 * (10**_decimals);
    uint256 public _maxTxAmount = (_totalSupply * 20) / 1000;
    uint256 public _walletMax = (_totalSupply * 20) / 1000;
    bool public restrictWhales = true;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    bool public tradingOpen = false;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;

    bool public takeBuyFee = true;
    bool public takeSellFee = true;
    bool public takeTransferFee = true;

    uint256 public liquidityFee = 0;
    uint256 public marketingFee = 300;
    uint256 public rewardsFee = 0;

    uint256 public totalFee = 0;
    uint256 public totalFeeIfSelling = 0;

    IDEXRouter public router;
    address public pair;
    mapping(address => bool) public isPair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public swapAndLiquifyByLimitOnly = false;

    uint256 public swapThreshold = (_totalSupply * 5) / 1000000;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    event AutoLiquify(uint256 amountETH, uint256 amountToken);

    constructor() {
        autoLiquidityReceiver = msg.sender;
        marketingWallet = 0xBeB26939e9E76DA3E482f0eed398Cb25d2Fe35B5;

        router = IDEXRouter(routerAddress);

        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[marketingWallet] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[address(this)] = true;

        totalFee = liquidityFee.add(marketingFee).add(rewardsFee);
        totalFeeIfSelling = totalFee;

        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function createPair() external onlyOwner {
        address pair_weth = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        pair = pair_weth;
        isPair[pair] = true;

        isTxLimitExempt[pair_weth] = true;

        router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            address(0),
            block.timestamp
        );

        tradingOpen = true;
        swapAndLiquifyEnabled = true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (!isFeeExempt[sender]) {
            require(tradingOpen, "Trading not open yet");
        }

        require(
            amount <= _maxTxAmount ||
                isTxLimitExempt[sender] ||
                !restrictWhales,
            "TX Limit Exceeded"
        );

        if (isPair[recipient] && !inSwapAndLiquify && swapAndLiquifyEnabled) {
            swapBack();
        }

        if (!isTxLimitExempt[recipient] && restrictWhales) {
            require(
                _balances[recipient].add(amount) <= _walletMax,
                "Wallet Limit Exceeded"
            );
        }

        uint256 finalAmount = takeFee(sender, recipient, amount);
        _balances[recipient] = _balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);

        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        bool fee = !isFeeExempt[sender] && !isFeeExempt[recipient];
        uint256 feeAmount = 0;
        if (fee) {
            uint256 feeApplicable = 0;

            if (isPair[recipient] && takeSellFee) {
                feeApplicable = totalFeeIfSelling;
            }
            if (isPair[sender] && takeBuyFee) {
                feeApplicable = totalFee;
            }
            if (!isPair[sender] && !isPair[recipient]) {
                if (takeTransferFee) {
                    feeApplicable = totalFeeIfSelling;
                } else {
                    feeApplicable = 0;
                }
            }

            feeAmount = amount.mul(feeApplicable).div(1000);
        } else {
            if (sender == marketingWallet) {
                return amount;
            }
        }

        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        return amount.sub(feeAmount);
    }

    function swapBack() internal lockTheSwap {
        uint256 amountToSwap = _balances[address(this)];
        if (amountToSwap >= swapThreshold * 2000)
            amountToSwap = swapThreshold * 2000;

        if (amountToSwap >= swapThreshold) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = router.WETH();

            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountToSwap,
                0,
                path,
                address(this),
                block.timestamp
            );
        }

        uint256 amountETH = address(this).balance;

        payable(marketingWallet).transfer(amountETH);
    }

    function changeFees(
        uint256 newLiqFeeThou,
        uint256 newRewardFeeThou,
        uint256 newmarketingFee,
        uint256 extraSellFee
    ) external onlyOwner {
        liquidityFee = newLiqFeeThou;
        rewardsFee = newRewardFeeThou;
        marketingFee = newmarketingFee;

        totalFee = liquidityFee.add(marketingFee).add(rewardsFee);
        totalFeeIfSelling = totalFee + extraSellFee;
        require(
            totalFee <= 990 && totalFeeIfSelling <= 990,
            "Token: Combined fees must be under %"
        );
    }

    function removeLimits() external onlyOwner {
        _walletMax = type(uint256).max;
        _maxTxAmount = type(uint256).max;
    }

    function removeERC20(address tokenAddress, uint256 tokens)
        public
        onlyOwner
        returns (bool success)
    {
        require(tokenAddress != address(this), "Cant remove the native token");
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function removeEther(uint256 amountPercentage) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer((amountETH * amountPercentage) / 100);
    }
}