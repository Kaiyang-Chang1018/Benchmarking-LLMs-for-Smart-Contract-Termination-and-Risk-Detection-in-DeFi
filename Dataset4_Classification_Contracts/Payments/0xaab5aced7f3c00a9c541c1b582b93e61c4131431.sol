// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /*
    * @notice Creates new tokens and adds them to the specified account.
    * @dev The function creates a specified amount of tokens and adds them to the specified account, increasing the total supply accordingly.
    * @param account The account to which the tokens will be minted.
    * @param amount The amount of tokens to be minted.
    * @return It emits a Transfer event indicating the minting of tokens from the zero address to the specified account.
    */ 
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /*
    * @notice Burns a specific amount of tokens from the specified account.
    * @dev The function reduces the balance of the specified account by the specified amount and decreases the total supply accordingly.
    * @param account The account from which the tokens will be burned.
    * @param amount The amount of tokens to be burned.
    * @return It emits a Transfer event indicating the burning of tokens from the account to the zero address.
    */ 
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

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

    /*
    * @notice Hook that is called before transferring tokens.
    * @dev This function is called before transferring tokens from one account to another.
    * @param from The account from which the tokens are being transferred.
    * @param to The account to which the tokens are being transferred.
    * @param amount The amount of tokens being transferred.
    */ 
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract SyncOrbit is ERC20, Ownable {
    uint256 private  mintAmount = 25000 * 10**uint256(decimals());
    uint256 private constant mintETHAmount = 0.1 ether;
    bool public saleActive = true;
    mapping(address => bool) public liquidityProviders;
    uint256 private eventCounter; 

    event Mint(uint256 indexed  eventId,address indexed minter, uint256 indexed value);

    constructor () ERC20("SyncOrbit", "ORBT") 
    {   
        _mint(address(this), 1e9 * (10 ** decimals()));
        eventCounter = 0; 
    }

    receive() external payable {}

  
    function mint() external payable {
        require(saleActive, "Public sale has ended");
        require(owner() != address(0), "Owner address is zero, operation not allowed");
        require(msg.value >= mintETHAmount, "Send at least 0.1 ETH");
        uint256 mintQuantity = (msg.value * mintAmount) / mintETHAmount;
        // Check if there are enough tokens left in the contract
        require(balanceOf(address(this)) >= mintQuantity, "Insufficient tokens remaining");
        // Transferring tokens to users
        super._transfer(address(this), msg.sender, mintQuantity); 
        eventCounter++;   
        emit Mint(eventCounter, msg.sender, msg.value);
    }

    function closeSaleActive() external onlyOwner{
        require(saleActive, "Public sale has ended");
        saleActive = false;
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function distribute(address[] memory recipients, uint256 amount) external onlyOwner{
        require(owner() != address(0), "Owner address is zero, operation not allowed");
        for (uint i = 0; i < recipients.length; i++) {
              super._transfer(address(this), recipients[i], amount);
        }
    }

    function _transfer(address from,address to,uint256 amount) internal  override {
        require(from != address(0), "ERC20: transfer from the zero address");
        
         if (isRestrictedLiquidityAddition(to)) {
            revert("Only whitelisted addresses can add liquidity before public sale ends.");
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        super._transfer(from, to, amount);
    }


    function isRestrictedLiquidityAddition(address to) internal view returns (bool) {
        return isContract(to) && (!liquidityProviders[to] && saleActive);
    }

    function addLiquidityProvider1(address _addr) external onlyOwner {
        liquidityProviders[_addr] = true;
    }

    function removeLiquidityProvider1(address _addr) external onlyOwner {
        liquidityProviders[_addr] = false;
    }

    function withdraw(address tokenAddress, uint256 amount, address to) external onlyOwner {
        require(to != address(0), "Invalid recipient address");

        if (tokenAddress == address(0)) {
            require(amount <= address(this).balance, "Insufficient contract balance");
            (bool success, ) = payable(to).call{value: amount}("");
            require(success, "ETH transfer failed");
            return;
        }

        IERC20 token = IERC20(tokenAddress);
        uint256 contractBalance = token.balanceOf(address(this));

        require(amount <= contractBalance, "Insufficient balance in contract");

        bool tokenSuccess = token.transfer(to, amount);
        require(tokenSuccess, "Token transfer failed");
    }

}