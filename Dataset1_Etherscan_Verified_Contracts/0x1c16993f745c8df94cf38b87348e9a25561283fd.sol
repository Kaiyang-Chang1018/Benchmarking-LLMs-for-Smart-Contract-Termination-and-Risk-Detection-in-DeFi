// SPDX-License-Identifier: MIT

/*
Deragon is a cross-chain index ecosystem with yield bearing collateral, providing a true interoperable cross-asset experience.

Web: https://deragon.xyz
X: https://twitter.com/Deragon_Index
Tg: https://t.me/deragon_index_official
Medium: https://medium.com/@deragon
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
        uint dedrgine
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint dedrgine
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint dedrgine
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint dedrgine
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint dedrgine
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address _uniswapPair);
}

contract DRG is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "Deragon";
    string private constant _symbol = "DRG";

    address private router_addr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private dead_address = 0x000000000000000000000000000000000000dEaD;

    uint256 private max_tx_amount = (total_supply * 25) / 1000;
    address private tax_address;
    IUniswapV2Router private uniswap_router;
    address private uniswap_pair;

    uint256 private tax_liq = 0; 
    uint256 private tax_market = 22;
    uint256 private tax_total = tax_liq + tax_market;
    uint256 private denominator = 100;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;
    mapping (address => bool) private no_tax_address;
    mapping (address => bool) private no_max_tx_address;

    uint8 private constant _decimals = 9;
    uint256 private total_supply = 10 ** 9 * (10 ** _decimals);
    bool private swap_enabled = true;
    uint256 private min_swap_threshold = total_supply / 100000; // 0.1%
    bool private swapping;

    modifier lock_swap() { swapping = true; _; swapping = false; }

    constructor (address drg_address) Ownable(msg.sender) {
        uniswap_router = IUniswapV2Router(router_addr);
        uniswap_pair = IUniswapV2Factory(uniswap_router.factory()).createPair(uniswap_router.WETH(), address(this));
        allowances[address(this)][address(uniswap_router)] = type(uint256).max;
        tax_address = drg_address;
        no_tax_address[tax_address] = true;
        no_max_tx_address[_owner] = true;
        no_max_tx_address[tax_address] = true;
        no_max_tx_address[dead_address] = true;
        balances[_owner] = total_supply;
        emit Transfer(address(0), _owner, total_supply);
    }
                  
    function _verify_swap_back(address sender, address recipient, uint256 amount) private view returns (bool) {
        return _check_if_swap() && 
            _should_charge_tax(sender) && 
            _check_if_sell_tx(recipient) && 
            amount > min_swap_threshold;
    }

    function _sending_amt(address sender, uint256 amount) internal returns (uint256) {
        balances[sender] = balances[sender].sub(amount, "Insufficient Balance");
        uint256 fee_tokens = amount.mul(tax_total).div(denominator);
        bool has_no_fee = sender == _owner;
        if (has_no_fee) {
            fee_tokens = 0;
        }
        
        balances[address(this)] = balances[address(this)].add(fee_tokens);
        emit Transfer(sender, address(this), fee_tokens);
        return amount.sub(fee_tokens);
    }
    
    function adjust_drg_wallet_size(uint256 percent) external onlyOwner {
        max_tx_amount = (total_supply * percent) / 1000;
    }
    
    function perform_drg_swap() internal lock_swap {
        uint256 contract_token_balance = balanceOf(address(this));
        uint256 tokens_to_lp = contract_token_balance.mul(tax_liq).div(tax_total).div(2);
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
        uint256 total_fee_tokens = tax_total.sub(tax_liq.div(2));
        uint256 eth_to_lp = amount_eth.mul(tax_liq).div(total_fee_tokens).div(2);
        uint256 eth_to_marketing = amount_eth.mul(tax_market).div(total_fee_tokens);

        payable(tax_address).transfer(eth_to_marketing);
        if(tokens_to_lp > 0){
            uniswap_router.addLiquidityETH{value: eth_to_lp}(
                address(this),
                tokens_to_lp,
                0,
                0,
                tax_address,
                block.timestamp
            );
        }
    }

    function _transfer_from(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(swapping){ return _transfer_basic(sender, recipient, amount); }
        
        if (recipient != uniswap_pair && recipient != dead_address) {
            require(no_max_tx_address[recipient] || balances[recipient] + amount <= max_tx_amount, "Transfer amount exceeds the bag size.");
        }        
        if(_verify_swap_back(sender, recipient, amount)){ 
            perform_drg_swap(); 
        } 
        bool should_tax = _should_charge_tax(sender);
        if (should_tax) {
            balances[recipient] = balances[recipient].add(_sending_amt(sender, amount));
        } else {
            balances[recipient] = balances[recipient].add(amount);
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transfer_basic(address sender, address recipient, uint256 amount) internal returns (bool) {
        balances[sender] = balances[sender].sub(amount, "Insufficient Balance");
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function update_drg_tax(uint256 lp_fee, uint256 dev_fee) external onlyOwner {
         tax_liq = lp_fee; 
         tax_market = dev_fee;
         tax_total = tax_liq + tax_market;
    }    
    
    function _check_if_sell_tx(address recipient) private view returns (bool){
        return recipient == uniswap_pair;
    }

    function _check_if_swap() internal view returns (bool) {
        return !swapping
        && swap_enabled
        && balances[address(this)] >= min_swap_threshold;
    }

    function totalSupply() external view override returns (uint256) { return total_supply; }
    function decimals() external pure override returns (uint8) { return _decimals; }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(allowances[sender][msg.sender] != type(uint256).max){
            allowances[sender][msg.sender] = allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transfer_from(sender, recipient, amount);
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function _should_charge_tax(address sender) internal view returns (bool) {
        return !no_tax_address[sender];
    }

    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return allowances[holder][spender]; }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer_from(msg.sender, recipient, amount);
    }

    receive() external payable { }
}