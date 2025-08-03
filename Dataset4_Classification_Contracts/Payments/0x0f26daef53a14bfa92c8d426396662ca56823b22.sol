// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract XPayBotRouter {
    address public owner;
    address public feeReceiver;
    address public revShareReceiver;
    address public router;
    uint public fee;
    uint public feeDenominator;
    uint public feeRatio;
    bool private _entered;

    /* ========== EVENTS ========== */

    event FeeCollected(uint fee);
    event RevShareCollected(uint revShare);

    /* ========== CONSTRUCTOR ========== */

    /* @dev On deployment, set the owner, fee receiver, fee % and router
     * @notice The fee is in percentage (100 = 0.1%) and the deployer is the owner
     * @param _router address of the UniswapV2Router
     * @param _fee fee in percentage (100 = 0.1%)
     * @param _feeRatio ratio between the fees
     */
    constructor(address _router, uint _fee, uint _feeRatio) {
        owner = msg.sender;
        feeReceiver = msg.sender;
        revShareReceiver = msg.sender;
        fee = _fee;
        feeRatio = _feeRatio;
        feeDenominator = 100000;
        router = _router;
    }

    // accept ETH
    receive() external payable {}

    /* ========== MODIFIERS ========== */
    modifier nonReentrant {
        require(!_entered, "ReentrancyGuard: reentrant call");
        _entered = true;
        _;
        _entered = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /* ========== OWNER FUNCTIONS ========== */

    /**
     * @dev Set the fee receiver
     * @param _feeReceiver address of the fee receiver
     */
    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        feeReceiver = _feeReceiver;
    }

    /**
     * @dev Set the rev share receiver
     * @param _revShareReceiver address of the rev share receiver
     */
    function setRevShareReceiver(address _revShareReceiver) external onlyOwner {
        revShareReceiver = _revShareReceiver;
    }

    /**
     * @dev Set the owner
     * @param _owner address of the new owner
     */
    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    /**
     * @dev Set the router
     * @param _router address of the new router
     */
    function setRouter(address _router) external onlyOwner {
        router = _router;
    }

    /**
     * @dev Set the fee (in percentage, 100 = 0.1%)
     * @param _fee new fee value (in percentage)
     */
    function setFee(uint _fee) external onlyOwner {
        fee = _fee;
    }

    function setFeeRatio(uint _feeRatio) external onlyOwner {
        require(_feeRatio > 0, "Fee ratio must be greater than 0");
        require(_feeRatio <= 100, "Fee ratio must be less than or equal to 100");
        feeRatio = _feeRatio;
    }

    /**
     * @dev Set the fee denominator (default is 100000, 100 = 0.1%)
     * @param _feeDenominator new fee denominator
     */
    function setFeeDenominator(uint _feeDenominator) external onlyOwner {
        feeDenominator = _feeDenominator;
    }

    /**
     * @dev Withdraw all ERC20 from the contract
     * @param _token address of the token to withdraw
     */
    function getStuckTokens(address _token) external onlyOwner {
        IERC20 token = IERC20(_token);
        token.transfer(owner, token.balanceOf(address(this)));
    }

    /**
     * @dev Withdraw all ETH from the contract
     */
    function getStuckETH() external onlyOwner {
        (bool success,) = owner.call{value: address(this).balance}("");
        require(success, "Failed to send ETH to owner");
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    /**
     * @dev Swap ETH for Tokens, applying our custom fee before doing the trade
     * @param amountOutMin minimum amount of tokens to receive
     * @param path array of addresses representing the path to trade
     * @param to address to receive the tokens
     * @param deadline deadline for the trade
     */
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable nonReentrant {
        uint feeAmount = msg.value * fee / feeDenominator;
        uint feeReceiverAmount = feeAmount * feeRatio / 100;
        uint revShareAmount = feeAmount - feeReceiverAmount;
        (bool success,) = feeReceiver.call{value: feeReceiverAmount}("");
        require(success, "Failed to send fee to feeReceiver");
        emit FeeCollected(feeReceiverAmount);
        (success,) = revShareReceiver.call{value: revShareAmount}("");
        require(success, "Failed to send fee to revShareReceiver");
        emit RevShareCollected(revShareAmount);

        IUniswapV2Router02(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value - feeAmount}(amountOutMin, path, to, deadline);
    }

    /**
     * @dev Swap Tokens for ETH, applying our custom fee after doing the trade
     * @param amountIn amount of tokens to swap
     * @param amountOutMin minimum amount of ETH to receive
     * @param path array of addresses representing the path to trade
     * @param to address to receive the ETH
     * @param deadline deadline for the trade
     */
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external nonReentrant {
        // move tokens from user to router
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // approve router
        IERC20(path[0]).approve(router, amountIn);
        // save router ETH balance
        uint balanceBefore = address(this).balance;
        // swap tokens for ETH
        IUniswapV2Router02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, address(this), deadline);

        uint newBalance = address(this).balance - balanceBefore;
        uint feeAmount = newBalance * fee / feeDenominator;
        uint feeReceiverAmount = feeAmount * feeRatio / 100;
        uint revShareAmount = feeAmount - feeReceiverAmount;
        (bool success,) = feeReceiver.call{value: feeReceiverAmount}("");
        require(success, "Failed to send fee to feeReceiver");
        emit FeeCollected(feeReceiverAmount);
        (success,) = revShareReceiver.call{value: revShareAmount}("");
        require(success, "Failed to send fee to revShareReceiver");
        emit RevShareCollected(revShareAmount);

        (success,) = to.call{value: newBalance - feeAmount}("");
        require(success, "Failed to send ETH to recipient");
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @dev Get the amount of tokens that will be received for a given amount of input tokens
     * @param amountIn amount of input tokens
     * @param path array of addresses representing the path to trade
     * @return amounts array of amounts of tokens that will be received
     */
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory) {
        return IUniswapV2Router02(router).getAmountsOut(amountIn, path);
    }
}