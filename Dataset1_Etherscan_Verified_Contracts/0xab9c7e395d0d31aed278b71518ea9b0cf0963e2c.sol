/**
ooooooooooooo ooooo   ooooo ooooooooo.   oooooooooooo oooooooooooo 
8'   888   `8 `888'   `888' `888   `Y88. `888'     `8 `888'     `8 
     888       888     888   888   .d88'  888          888         
     888       888ooooo888   888ooo88P'   888oooo8     888oooo8    
     888       888     888   888`88b.     888    "     888    "    
     888       888     888   888  `88b.   888       o  888       o 
    o888o     o888o   o888o o888o  o888o o888ooooood8 o888ooooood8 

    $THREE Protocol
Website: https://www.threeprotocol.ai/
Twitter: https://twitter.com/threeprotocol
Telegram: https://t.me/threeprotocol
Litepaper: https://three-3.gitbook.io/litepaper
Reddit: https://www.reddit.com/r/jobs3/
Linkedin: https://uk.linkedin.com/company/threeprotocol
Job3 Website: https://www.jobs3.io/

**/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
pragma experimental ABIEncoderV2;

abstract contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
    }
}

library SafeERC20 {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: INTERNAL TRANSFER_FAILED');
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract ThreeProtocol is Ownable {
    string private constant _name = unicode"Three Protocol";
    string private constant _symbol = unicode"THREE";
    uint256 private constant _totalSupply = 100_000_000 * 1e18;

    uint256 public maxTransactionAmount = 500_000 * 1e18;
    uint256 public maxWallet = 500_000 * 1e18;
    uint256 public swapTokensAtAmount = (_totalSupply * 2) / 10000;

    address private revWallet = 0xfeFF1c318046676D276658A9f32F9AB152d8F5FF;
    address private stakingWallet = 0x8C616Aa199de6533C4fB5408b8c1BbEAfE3460e8;
    address private teamWallet = 0x4f02BC0E3C0A2176Ff466E72D17013E1cEb472ab;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint8 public buyTotalFees = 5;
    uint8 public sellTotalFees = 5;

    uint8 public revFee = 25;
    uint8 public stakingFee = 25;
    uint8 public teamFee = 50;

    bool private swapping;
    bool public limitsInEffect = true;
    bool private launched;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedMaxTransactionAmount;
    mapping(address => bool) private automatedMarketMakerPairs;

    event SwapAndLiquify(uint256 tokensSwapped, uint256 teamETH, uint256 revETH, uint256 StakingETH);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public immutable uniswapV2Pair;

    constructor() {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), WETH);
        automatedMarketMakerPairs[uniswapV2Pair] = true;

        address airdropWallet = 0x3a06Ae2Ed9d8e0bC1f4ecA13d50448190170F7c1;

        setExcludedFromFees(owner(), true);
        setExcludedFromFees(address(this), true);
        setExcludedFromFees(address(0xdead), true);
        setExcludedFromFees(teamWallet, true);
        setExcludedFromFees(revWallet, true);
        setExcludedFromFees(stakingWallet, true);

        setExcludedFromMaxTransaction(owner(), true);
        setExcludedFromMaxTransaction(address(uniswapV2Router), true);
        setExcludedFromMaxTransaction(address(this), true);
        setExcludedFromMaxTransaction(address(0xdead), true);
        setExcludedFromMaxTransaction(address(uniswapV2Pair), true);
        setExcludedFromMaxTransaction(teamWallet, true);
        setExcludedFromMaxTransaction(revWallet, true);
        setExcludedFromMaxTransaction(stakingWallet, true);

        _balances[msg.sender] = 15_000_000 * 1e18;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
        _balances[stakingWallet] = 10_000_000 * 1e18;
        emit Transfer(address(0), stakingWallet, _balances[stakingWallet]);
        _balances[airdropWallet] = 500_000 * 1e18;
        emit Transfer(address(0), airdropWallet, _balances[airdropWallet]);
        _balances[address(this)] = 74_500_000 * 1e18;
        emit Transfer(address(0), address(this), _balances[address(this)]);

        _approve(address(this), address(uniswapV2Router), type(uint256).max);
    }

    receive() external payable {}

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, msg.sender, currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!launched && (from != owner() && from != address(this) && to != owner())) {
            revert("Trading not enabled");
        }

        if (limitsInEffect) {
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !swapping) {
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTx");
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                } else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    require(amount <= maxTransactionAmount,"Sell transfer amount exceeds the maxTx");
                } else if (!_isExcludedMaxTransactionAmount[to]) {
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                }
            }
        }

        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;

        if (canSwap && !swapping && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 fees = 0;
        if (takeFee) {
            if (automatedMarketMakerPairs[to] && sellTotalFees > 0) {
                fees = (amount * sellTotalFees) / 100;
            } else if (automatedMarketMakerPairs[from] && buyTotalFees > 0) {
                fees = (amount * buyTotalFees) / 100;
            }

            if (fees > 0) {
                unchecked {
                    amount = amount - fees;
                    _balances[from] -= fees;
                    _balances[address(this)] += fees;
                }
                emit Transfer(from, address(this), fees);
            }
        }
        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function removeLimits() external onlyOwner {
        limitsInEffect = false;
    }

    function setDistributionFees(uint8 _RevFee, uint8 _StakingFee, uint8 _teamFee) external onlyOwner {
        revFee = _RevFee;
        stakingFee = _StakingFee;
        teamFee = _teamFee;
        require((revFee + stakingFee + teamFee) == 100, "Distribution have to be equal to 100%");
    }

    function setFees(uint8 _buyTotalFees, uint8 _sellTotalFees) external onlyOwner {
        require(_buyTotalFees <= 5, "Buy fees must be less than or equal to 5%");
        require(_sellTotalFees <= 5, "Sell fees must be less than or equal to 5%");
        buyTotalFees = _buyTotalFees;
        sellTotalFees = _sellTotalFees;
    }

    function setExcludedFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }

    function setExcludedFromMaxTransaction(address account, bool excluded) public onlyOwner {
        _isExcludedMaxTransactionAmount[account] = excluded;
    }

    function airdropWallets(address[] memory addresses, uint256[] memory amounts) external onlyOwner {
        require(!launched, "Already launched");
        for (uint256 i = 0; i < addresses.length; i++) {
            require(_balances[msg.sender] >= amounts[i], "ERC20: transfer amount exceeds balance");
            _balances[addresses[i]] += amounts[i];
            _balances[msg.sender] -= amounts[i];
            emit Transfer(msg.sender, addresses[i], amounts[i]);
        }
    }

    function openTrade() external onlyOwner {
        require(!launched, "Already launched");
        launched = true;
    }

    function unleashTheThreeProtocol() external payable onlyOwner {
        require(!launched, "Already launched");
        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            _balances[address(this)],
            0,
            0,
            teamWallet,
            block.timestamp
        );
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed");
        automatedMarketMakerPairs[pair] = value;
    }

    function setSwapAtAmount(uint256 newSwapAmount) external onlyOwner {
        require(newSwapAmount >= (totalSupply() * 1) / 100000, "Swap amount cannot be lower than 0.001% of the supply");
        require(newSwapAmount <= (totalSupply() * 5) / 1000, "Swap amount cannot be higher than 0.5% of the supply");
        swapTokensAtAmount = newSwapAmount;
    }

    function setMaxTxnAmount(uint256 newMaxTx) external onlyOwner {
        require(newMaxTx >= ((totalSupply() * 1) / 10000) / 1e18, "Cannot set max transaction lower than 0.01%");
        maxTransactionAmount = newMaxTx * (10**18);
    }

    function setMaxWalletAmount(uint256 newMaxWallet) external onlyOwner {
        require(newMaxWallet >= ((totalSupply() * 1) / 10000) / 1e18, "Cannot set max wallet lower than 0.01%");
        maxWallet = newMaxWallet * (10**18);
    }

    function updateRevWallet(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Address cannot be zero");
        revWallet = newAddress;
    }

    function updateStakingWallet(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Address cannot be zero");
        stakingWallet = newAddress;
    }

    function updateTeamWallet(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Address cannot be zero");
        teamWallet = newAddress;
    }

    function excludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawStuckToken(address token, address to) external onlyOwner {
        uint256 _contractBalance = IERC20(token).balanceOf(address(this));
        SafeERC20.safeTransfer(token, to, _contractBalance); // Use safeTransfer
    }

    function withdrawStuckETH(address addr) external onlyOwner {
        require(addr != address(0), "Invalid address");

        (bool success, ) = addr.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }

    function swapBack() private {
        uint256 swapThreshold = swapTokensAtAmount;
        bool success;

        if (balanceOf(address(this)) > swapTokensAtAmount * 20) {
            swapThreshold = swapTokensAtAmount * 20;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(swapThreshold, 0, path, address(this), block.timestamp);

        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            uint256 ethForRev = (ethBalance * revFee) / 100;
            uint256 ethForTeam = (ethBalance * teamFee) / 100;
            uint256 ethForStaking = ethBalance - ethForRev - ethForTeam;

            (success, ) = address(teamWallet).call{value: ethForTeam}("");
            (success, ) = address(stakingWallet).call{value: ethForStaking}("");
            (success, ) = address(revWallet).call{value: ethForRev}("");

            emit SwapAndLiquify(swapThreshold, ethForTeam, ethForRev, ethForStaking);
        }
    }
}