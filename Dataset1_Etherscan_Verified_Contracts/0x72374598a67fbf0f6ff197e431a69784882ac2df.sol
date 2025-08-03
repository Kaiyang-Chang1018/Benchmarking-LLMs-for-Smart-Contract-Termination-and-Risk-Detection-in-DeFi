// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;

interface IUniswapV2Router {
    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function WETH() external pure returns (address);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract SnipeAndBribe {
    address public uniswapRouter;
    address public WETH;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _uniswapRouter) {
        uniswapRouter = _uniswapRouter;
        WETH = IUniswapV2Router(_uniswapRouter).WETH();
        owner = msg.sender;
    }

    // Function to buy tokens and send a tip to the block miner
    function buyTokensAndTip(
        uint256 _amountOut,      // The exact amount of tokens to buy
        address _token,       // The token you want to buy
        uint256 _tipAmount       // Amount of ETH to tip the miner
    ) external payable {
        require(msg.value >= _tipAmount, "Insufficient ETH for tip");
        // Check if the owner already holds the token
        uint256 ownerTokenBalance = IERC20(_token).balanceOf(msg.sender);
        require(ownerTokenBalance == 0, "Sender already holds the token, stopping");

        // Calculate the amount of ETH to use for the swap
        uint amountETHForSwap = msg.value - _tipAmount;

        // Uniswap V2 path: WETH -> token
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = _token;

        // Execute the swap
        IUniswapV2Router(uniswapRouter).swapETHForExactTokens{value: amountETHForSwap}(
            _amountOut,
            path,
            msg.sender,
            99999999999999999999999999999
        );

        // Send the tip to the block miner
        (bool sent, ) = block.coinbase.call{value: _tipAmount}("");
        require(sent, "Failed to send tip to miner");

        // Refund any leftover ETH to the sender
        if (address(this).balance > 0) {
            (sent, ) = msg.sender.call{value: address(this).balance}("");
            require(sent, "Failed to refund ETH");
        }
    }

    // Recover any ETH in the contract
    function recoverETH() external onlyOwner {
        (bool sent, ) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to recover ETH");
    }

    // Recover any ERC-20 tokens in the contract
    function recoverTokens(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "No tokens to recover");
        require(IERC20(token).transfer(owner, balance), "Failed to recover tokens");
    }

    // Function to receive ETH when msg.data is empty
    receive() external payable {}
}