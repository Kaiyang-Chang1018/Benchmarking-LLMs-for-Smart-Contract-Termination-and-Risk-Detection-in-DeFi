// SPDX-License-Identifier: MIT
//
// ███████╗██╗      ██████╗ ███╗   ██╗
// ██╔════╝██║     ██╔═══██╗████╗  ██║
// █████╗  ██║     ██║   ██║██╔██╗ ██║
// ██╔══╝  ██║     ██║   ██║██║╚██╗██║
// ███████╗███████╗╚██████╔╝██║ ╚████║
// ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝
// ██████╗  █████╗ ██╗██████╗ ███████╗
// ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝
// ██████╔╝███████║██║██║  ██║███████╗
// ██╔══██╗██╔══██║██║██║  ██║╚════██║
// ██║  ██║██║  ██║██║██████╔╝███████║
// ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
// ███╗   ███╗ █████╗ ██████╗ ███████╗
// ████╗ ████║██╔══██╗██╔══██╗██╔════╝
// ██╔████╔██║███████║██████╔╝███████╗
// ██║╚██╔╝██║██╔══██║██╔══██╗╚════██║
// ██║ ╚═╝ ██║██║  ██║██║  ██║███████║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
//
// ELON RAIDS MARS ($RAID)
// ERC-20 Token Contract V2 (taxless)
//
// https://ElonRaidsMars.com
// https://t.me/ElonRaidsMars
// https://x.com/ElonRaidsMars

pragma solidity ^0.8.28;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract RAID {
    string public name = "Elon Raids Mars";
    string public symbol = "RAID";
    uint8 public decimals = 18;
    uint256 public totalSupply = 100_000_000 * 10 ** 18;
    address public owner;
    address public uniswapPair;
    bool public tradingEnabled;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function enableTrading() external onlyOwner {
        tradingEnabled = true;
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

    function _beforeTransfer(address from, address to) internal view {
        if (!tradingEnabled && (from == uniswapPair || to == uniswapPair)) {
            require(from == owner || to == owner, "Trading not enabled");
        }
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Not enough balance");
        _beforeTransfer(msg.sender, to);
        unchecked { balanceOf[msg.sender] -= amount; }
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Not enough balance");
        require(allowance[from][msg.sender] >= amount, "Not enough allowance");
        _beforeTransfer(from, to);
        unchecked {
            balanceOf[from] -= amount;
            allowance[from][msg.sender] -= amount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function website() public pure returns (string memory) {
        return "https://ElonRaidsMars.com/";
    }
}