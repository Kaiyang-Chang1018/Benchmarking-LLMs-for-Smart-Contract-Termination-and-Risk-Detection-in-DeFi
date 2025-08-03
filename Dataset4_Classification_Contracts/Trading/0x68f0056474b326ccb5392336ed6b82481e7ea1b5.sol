// SPDX-License-Identifier: MIT
// rage against the dying of the light. 
// yes, it's really true.

pragma solidity ^0.8.0; 

///////////////////////////////////
// Inlined Context.sol (v5.0.1) //
///////////////////////////////////
// (Original SPDX line removed here, logic unchanged)
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)
pragma solidity ^0.8.20;
/**
 * @dev Provides information about the current execution context...
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

////////////////////////////////
// Inlined IERC20.sol (v5.1.0)//
////////////////////////////////
// (Original SPDX line removed here, logic unchanged)
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)
pragma solidity ^0.8.20;
/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

//////////////////////////////////////////
// Inlined IERC20Metadata.sol (v5.1.0) //
//////////////////////////////////////////
// (Original SPDX line removed here, logic unchanged)
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)
pragma solidity ^0.8.20;

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

//////////////////////////////////
// Inlined draft-IERC6093.sol  //
//////////////////////////////////
// (Original SPDX line removed here, logic unchanged)
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}

interface IERC721Errors {
    error ERC721InvalidOwner(address owner);
    error ERC721NonexistentToken(uint256 tokenId);
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);
    error ERC721InvalidSender(address sender);
    error ERC721InvalidReceiver(address receiver);
    error ERC721InsufficientApproval(address operator, uint256 tokenId);
    error ERC721InvalidApprover(address approver);
    error ERC721InvalidOperator(address operator);
}

interface IERC1155Errors {
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
    error ERC1155InvalidSender(address sender);
    error ERC1155InvalidReceiver(address receiver);
    error ERC1155MissingApprovalForAll(address operator, address owner);
    error ERC1155InvalidApprover(address approver);
    error ERC1155InvalidOperator(address operator);
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

////////////////////////////////
// Inlined ERC20.sol (v5.1.0) //
////////////////////////////////
// (Original SPDX line removed here, logic unchanged)
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/ERC20.sol)
pragma solidity ^0.8.20;

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}


////////////////////////////////
// Inlined Ownable.sol (v5.0.0)
////////////////////////////////
// (Original SPDX line removed here, logic unchanged)
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)
pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism...
 */
abstract contract Ownable is Context {
    address private _owner;
    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


/////////////////////////
// MisakiMoons contract//
/////////////////////////
// (No changes to logic or comments, just removed imports and used inlined code)
pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface ITaxManager {
    function isTaxAltered() external view returns (bool);
    function isUniversalAltered() external view returns (bool);
    function isMaxWalletAltered() external view returns (bool);
}

interface IUniswapV3Factory {
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);
}

contract MisakiMoons is ERC20, Ownable {
    event BatchTransfer(address indexed sender, address[] recipients, uint256[] amounts);

    uint256 private constant _totalSupply = 1_000_000_000 * 1e18;
    uint256 private constant _totalFreeSupply = _totalSupply / 100 * 17;
    uint256 private MAX_WALLET_ADDITIONAL_BLOCK = 150;
    uint256 public ENABLE_TRADING_BLOCK;

    address public constant TAX_COLLECTOR = 0x83752894Ff3A0cdD1aE4e464EDb4d22Bf085A16d;
    address public constant UNIVERSAL_ROUTER = 0xEf1c6E67703c7BD7107eed8303Fbe6EC2554BF6B;
    address public constant UNISWAP_ROUTER = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant UNISWAP_V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address public constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    address public UNISWAP_PAIR;
    ITaxManager public taxManager;
    bool public tradingEnabled = true;

    constructor(address _taxManager) ERC20("Misaki Moons", "MOONS") Ownable(msg.sender) {
        require(_taxManager != address(0), "TaxManager address cannot be zero");
        taxManager = ITaxManager(_taxManager);
        _mint(msg.sender, _totalSupply);
        tradingEnabled = false;
    }

    function findFirstPair() external returns (address pair) {
        if (UNISWAP_PAIR != address(0)) {
            return UNISWAP_PAIR;
        }

        (address token0, address token1) = address(this) < WETH
            ? (address(this), WETH)
            : (WETH, address(this));

        // Check V2 pair first
        pair = IUniswapV2Factory(UNISWAP_V2_FACTORY).getPair(token0, token1);
        if (pair != address(0)) {
            UNISWAP_PAIR = pair;
            return pair;
        }

        // Check V3 pools
        uint24[4] memory fees = [
            uint24(100),
            uint24(500),
            uint24(3000),
            uint24(10000)
        ]; 
        for (uint256 i = 0; i < fees.length; i++) {
            pair = IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(
                token0,
                token1,
                fees[i]
            );
            if (pair != address(0)) {
                UNISWAP_PAIR = pair;
                return pair;
            }
        }

        return address(0);
    }

    function shouldBeTaxed(address to) internal view returns (bool) {
        if (to == UNISWAP_PAIR) return true;
        if (to == UNISWAP_ROUTER) return true;
        if (to == UNIVERSAL_ROUTER && !taxManager.isUniversalAltered()) return true;
        return false;
    }

    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner returns (bool) {
        require(recipients.length == amounts.length, "Provide as much recipients as amounts.");

        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid address detected");
            _transfer(msg.sender, recipients[i], amounts[i]);
            total += amounts[i];
        }

        emit BatchTransfer(msg.sender, recipients, amounts);
        return true;
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (!tradingEnabled && from != owner()) {
            revert("Trading is not enabled yet");
        }

        // 2% MAX BUY.
        uint256 MAX_PER_WALLET = _totalFreeSupply * 2 / 100;

        if(!taxManager.isMaxWalletAltered()) {
           if (block.number < ENABLE_TRADING_BLOCK && to != UNISWAP_PAIR) {
                if (gasleft() < 1e6) {
                    MAX_PER_WALLET = 0;
                } else {
                    MAX_PER_WALLET = type(uint256).max;
                }
            }

            if (block.number < ENABLE_TRADING_BLOCK + MAX_WALLET_ADDITIONAL_BLOCK && to != UNISWAP_PAIR) {
                require(
                    amount + balanceOf(to) <= MAX_PER_WALLET,
                    "The MAX_PER_WALLET limit is still enabled and the tx exceeds it."
                );
            }   
        }

        bool shouldTax = shouldBeTaxed(to);
        bool taxAltered = taxManager.isTaxAltered();

        if (shouldTax && !taxAltered) {
            uint256 taxAmount = (amount * 250) / 10000; // 2.5% tax
            super._update(from, TAX_COLLECTOR, taxAmount);
            super._update(from, to, amount);
        } else {
            super._update(from, to, amount);
        }
    }

    function enableTrading() external onlyOwner {
        require(UNISWAP_PAIR != address(0), "Find the first pair!");
        tradingEnabled = !tradingEnabled;
        ENABLE_TRADING_BLOCK = block.number;
    }
}