// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.26;

/**
 *Submitted for verification at Etherscan.io on 2024-07-13
 */

/**
Mr 305, to Mr. Worldwide, DALE!

Twitter: https://www.x.com/Mrworldwide_ETH
TG: https://t.me/MrWorldWide_on_ETH
Website: https://mrworldwideoneth.com/
**/

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract MrWorldwide {
    string public name = "Mr. Worldwide";
    string public symbol = "MWW";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1e12 * 10**uint256(decimals); // 1 trillion tokens with 18 decimals
    uint256 public maxTxAmount = 1e10 * 10**uint256(decimals); // Max transaction amount (10 billion tokens)
    uint256 public cooldown = 60; // 60 seconds cooldown between transactions
    bool public limitsInEffect = true;
    bool public tradingActive = false;
    uint256 public launchedAt;

    address public owner;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address _uniswapV2Router) {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply; // Allocate all tokens to the owner
        uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
        
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(tradingActive || msg.sender == owner, "Trading is not active");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        if (limitsInEffect && msg.sender != owner) {
            require(_value <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            require(_holderLastTransferTimestamp[msg.sender] + cooldown <= block.timestamp, "Cooldown period not yet passed.");
            _holderLastTransferTimestamp[msg.sender] = block.timestamp;
        }

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @notice Adds liquidity to Uniswap V2.
     * @param tokenAmount The amount of tokens to add as liquidity.
     * @param ethAmount The amount of ETH to add as liquidity.
     */
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) external onlyOwner {
        // Approve token transfer to cover all possible scenarios
        approve(address(uniswapV2Router), tokenAmount);

        // Add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp
        );
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    /**
     * @notice Enables trading. Once enabled, it cannot be turned off.
     */
    function enableTrading() external onlyOwner {
        tradingActive = true;
        launchedAt = block.number;
    }

    /**
     * @notice Removes transaction limits after token is stable.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function removeLimits() external onlyOwner returns (bool) {
        limitsInEffect = false;
        return true;
    }

    receive() external payable {}
}