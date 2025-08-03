// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract LoginWithToken {
    // Address => timestamp
    mapping (address => uint256) public loginStarted;
    address public constant uniswapV2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address payable public receiver;
    address public owner;
    address public token;
    uint256 public loginAmount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor (address _token) {
        owner = msg.sender;
        token = _token;
        receiver = payable(msg.sender);
        loginAmount = 6000 * 1e18;
    }

    receive() external payable {}

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function setReceiver(address _receiver) public onlyOwner {
        receiver = payable(_receiver);
    }

    function setLoginAmount(uint256 _loginAmount) public onlyOwner {
        loginAmount = _loginAmount;
    }
    
    function setToken(address _token) public onlyOwner {
        token = _token;
    }

    function loginWithTokens() public {
        // Receive the tokens with a transferFrom
        // Swap the tokens for ETH
        // Send the ETH to the receiver account
        uint256 tokenBalance = IERC20(token).balanceOf(msg.sender);
        require(tokenBalance >= loginAmount, "Insufficient token balance");
        IERC20(token).transferFrom(msg.sender, address(this), loginAmount);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = IUniswapV2Router(uniswapV2).WETH();
        IERC20(token).approve(uniswapV2, loginAmount);
        uint256 tokenBalanceThis = IERC20(token).balanceOf(address(this));
        IUniswapV2Router(uniswapV2).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenBalanceThis,
            0,
            path,
            address(this),
            block.timestamp * 2
        );
        payable(receiver).transfer(address(this).balance);
        loginStarted[msg.sender] = block.timestamp;
    }

    function recoverETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function recoverStuckTokens(address _token) external onlyOwner {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(owner, balance);
    }
}