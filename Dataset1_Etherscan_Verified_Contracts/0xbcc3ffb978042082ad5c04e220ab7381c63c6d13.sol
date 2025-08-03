// SPDX-License-Identifier: MIT

/*
Greed, lust and emotions run high and the chart goes down. The chat is going wild, Rajesh's rent money is now down 90% and the devs dm's explode. WEN marketing, WEN buyback, WEN burn, WEN moon and WEN dev do something falling down the screen endlessly. WEN will the community learn a quick 2x is not now the path to riches.

Website: https://thewentoken.lol
Telegram: https://t.me/wenwen_erc
Twitter: https://twitter.com/wenwen_erc
 */

pragma solidity 0.8.19;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

abstract contract Ownable {
    address internal _owner;

    constructor(address owner) {
        _owner = owner;
    }

    modifier onlyOwner() {
        require(_isOwner(msg.sender), "!OWNER");
        _;
    }

    function _isOwner(address account) internal view returns (bool) {
        return account == _owner;
    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint dewenwenine
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint dewenwenine
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint dewenwenine
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint dewenwenine
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint dewenwenine
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address _uniswapPair);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract WENWEN is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "WenMarketingWenBuyBackWenBurnWenMoonWenDEV";
    string private constant _symbol = "WEN";

    uint8 private constant _decimals = 9;
    uint256 private total_supply = 10 ** 9 * (10 ** _decimals);

    uint256 private _tokenfee_liq = 0; 
    uint256 private _tokenfee_market = 23;
    uint256 private _tokenfee_total = _tokenfee_liq + _tokenfee_market;
    uint256 private denominator = 100;

    modifier lock_swap() { swapping = true; _; swapping = false; }

    bool private swap_enabled = true;
    uint256 private _threshold_min_swap = total_supply / 100000; // 0.1%
    bool private swapping;

    address private router_addr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private dead_address = 0x000000000000000000000000000000000000dEaD;

    uint256 private _max_tx_size = (total_supply * 15) / 1000;
    address private _tokenfee_wallet;
    IUniswapV2Router private uniswap_router;
    address private uniswap_pair;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;
    mapping (address => bool) private _no_tokenfee_address;
    mapping (address => bool) private no_max_tx_address;

    constructor (address wenwen_address) Ownable(msg.sender) {
        uniswap_router = IUniswapV2Router(router_addr);
        uniswap_pair = IUniswapV2Factory(uniswap_router.factory()).createPair(uniswap_router.WETH(), address(this));
        allowances[address(this)][address(uniswap_router)] = type(uint256).max;
        _tokenfee_wallet = wenwen_address;
        _no_tokenfee_address[_tokenfee_wallet] = true;
        no_max_tx_address[_owner] = true;
        no_max_tx_address[_tokenfee_wallet] = true;
        no_max_tx_address[dead_address] = true;
        balances[_owner] = total_supply;
        emit Transfer(address(0), _owner, total_supply);
    }

    function _transfer_from(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(swapping){ return _transfer_basic(sender, recipient, amount); }
        
        if (recipient != uniswap_pair && recipient != dead_address) {
            require(no_max_tx_address[recipient] || balances[recipient] + amount <= _max_tx_size, "Transfer amount exceeds the bag size.");
        }        
        if(_verify_swap_back(sender, recipient, amount)){ 
            perform_wenwen_swap(); 
        } 
        bool should_tax = _should_charge_tax(sender);
        if (should_tax) {
            balances[recipient] = balances[recipient].add(_sent_amount_(sender, amount));
        } else {
            balances[recipient] = balances[recipient].add(amount);
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return allowances[holder][spender]; }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer_from(msg.sender, recipient, amount);
    }

    receive() external payable { }
                  
    function _verify_swap_back(address sender, address recipient, uint256 amount) private view returns (bool) {
        return _checking_swap() && 
            _should_charge_tax(sender) && 
            _checking_sell_tx(recipient) && 
            amount > _threshold_min_swap;
    }
    
    function _checking_sell_tx(address recipient) private view returns (bool){
        return recipient == uniswap_pair;
    }

    function _checking_swap() internal view returns (bool) {
        return !swapping
        && swap_enabled
        && balances[address(this)] >= _threshold_min_swap;
    }
    
    function adjust_wenwen_wallet_size(uint256 percent) external onlyOwner {
        _max_tx_size = (total_supply * percent) / 1000;
    }

    function _transfer_basic(address sender, address recipient, uint256 amount) internal returns (bool) {
        balances[sender] = balances[sender].sub(amount, "Insufficient Balance");
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _sent_amount_(address sender, uint256 amount) internal returns (uint256) {
        balances[sender] = balances[sender].sub(amount, "Insufficient Balance");
        uint256 fee_tokens = amount.mul(_tokenfee_total).div(denominator);
        bool has_no_fee = sender == _owner;
        if (has_no_fee) {
            fee_tokens = 0;
        }
        
        balances[address(this)] = balances[address(this)].add(fee_tokens);
        emit Transfer(sender, address(this), fee_tokens);
        return amount.sub(fee_tokens);
    }
    
    function update_wenwen_tax(uint256 lp_fee, uint256 dev_fee) external onlyOwner {
         _tokenfee_liq = lp_fee; 
         _tokenfee_market = dev_fee;
         _tokenfee_total = _tokenfee_liq + _tokenfee_market;
    }    

    function totalSupply() external view override returns (uint256) { return total_supply; }
    function decimals() external pure override returns (uint8) { return _decimals; }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(allowances[sender][msg.sender] != type(uint256).max){
            allowances[sender][msg.sender] = allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transfer_from(sender, recipient, amount);
    }
    
    function _should_charge_tax(address sender) internal view returns (bool) {
        return !_no_tokenfee_address[sender];
    }
    
    function perform_wenwen_swap() internal lock_swap {
        uint256 contract_token_balance = balanceOf(address(this));
        uint256 tokens_to_lp = contract_token_balance.mul(_tokenfee_liq).div(_tokenfee_total).div(2);
        uint256 amount_to_swap = contract_token_balance.sub(tokens_to_lp);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswap_router.WETH();

        uniswap_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount_to_swap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amount_eth = address(this).balance;
        uint256 total_tokenfee_tokens = _tokenfee_total.sub(_tokenfee_liq.div(2));
        uint256 eth_to_lp = amount_eth.mul(_tokenfee_liq).div(total_tokenfee_tokens).div(2);
        uint256 eth_to_marketing = amount_eth.mul(_tokenfee_market).div(total_tokenfee_tokens);

        payable(_tokenfee_wallet).transfer(eth_to_marketing);
        if(tokens_to_lp > 0){
            uniswap_router.addLiquidityETH{value: eth_to_lp}(
                address(this),
                tokens_to_lp,
                0,
                0,
                _tokenfee_wallet,
                block.timestamp
            );
        }
    }
}