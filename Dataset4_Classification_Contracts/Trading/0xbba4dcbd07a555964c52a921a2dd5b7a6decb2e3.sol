//SPDX-License-Identifier: MIT

//                               ,--,                 ,----,   ,----..                                           ,--. 
//  .--.--.     ,----..        ,--.'|   ,---,       .'   .`|  /   /   \      ,---,.,-.----.       ,---,.       ,--.'| 
// /  /    '.  /   /   \    ,--,  | :,`--.' |    .'   .'   ; /   .     :   ,'  .' |\    /  \    ,'  .' |   ,--,:  : | 
//|  :  /`. / |   :     :,---.'|  : '|   :  :  ,---, '    .'.   /   ;.  \,---.'   |;   :    \ ,---.'   |,`--.'`|  ' : 
//;  |  |--`  .   |  ;. /|   | : _' |:   |  '  |   :     ./.   ;   /  ` ;|   |   .'|   | .\ : |   |   .'|   :  :  | | 
//|  :  ;_    .   ; /--` :   : |.'  ||   :  |  ;   | .'  / ;   |  ; \ ; |:   :  :  .   : |: | :   :  |-,:   |   \ | : 
// \  \    `. ;   | ;    |   ' '  ; :'   '  ;  `---' /  ;  |   :  | ; | ':   |  |-,|   |  \ : :   |  ;/||   : '  '; | 
//  `----.   \|   : |    '   |  .'. ||   |  |    /  ;  /   .   |  ' ' ' :|   :  ;/||   : .  / |   :   .''   ' ;.    ; 
//  __ \  \  |.   | '___ |   | :  | ''   :  ;   ;  /  /--, '   ;  \; /  ||   |   .';   | |  \ |   |  |-,|   | | \   | 
// /  /`--'  /'   ; : .'|'   : |  : ;|   |  '  /  /  / .`|  \   \  ',  / '   :  '  |   | ;\  \'   :  ;/|'   : |  ; .' 
//'--'.     / '   | '/  :|   | '  ,/ '   :  |./__;       :   ;   :    /  |   |  |  :   ' | \.'|   |    \|   | '`--'   
//  `--'---'  |   :    / ;   : ;--'  ;   |.' |   :     .'     \   \ .'   |   :  \  :   : :-'  |   :   .''   : |       
//             \   \ .'  |   ,/      '---'   ;   |  .'         `---`     |   | ,'  |   |.'    |   | ,'  ;   |.'       
//              `---`    '---'               `---'                       `----'    `---'      `----'    '---'           
//
//http://t.me/schizofrenportal

pragma solidity >=0.8.12 <0.9.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract SCHIZOFREN is IERC20 {
    using SafeMath for uint256;
    using SafeMath for uint8;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    address public MARKETINGWALLET = 0xDe8ebcDEdDc61Dda28D3637ceA792EAaBD35f04c;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public THRESHOLD;
    uint256 public SELLAMOUNT = 500000 * 10**8;

    address private _deployer;
    Tax private _tax;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private isPair;
    mapping(address => bool) private isExempt;

    address private _owner = address(0);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool inLiquidate;

    event Liquidate(address _marketingWallet);
    event SetMarketingWallet(address _marketingWallet);
    event TransferOwnership(address _newDev);
    event UpdateExempt(address _address, bool _isExempt);

    constructor() {
        name = "SCHIZOFREN";
        symbol = "SCHIZO";
        decimals = 8;
        
        _deployer = msg.sender;
        _tax = Tax(2, 2); //2% marketing 2% token burn
        _update(address(0), msg.sender, 1000000000 * 10**8);

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );

        THRESHOLD = totalSupply.div(1000); //0.1% swap threshold

        isPair[address(uniswapV2Pair)] = true;
        isExempt[msg.sender] = true;
        isExempt[address(this)] = true;

        allowance[address(this)][address(uniswapV2Pair)] = type(uint256).max;
        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;
    }

    struct Tax {
        uint8 marketingTax;
        uint8 burnTax;
    }

    receive() external payable {}

    modifier protected() {
        require(msg.sender == _deployer);
        _;
    }

    modifier lockLiquidate() {
        inLiquidate = true;
        _;
        inLiquidate = false;
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        uint256 availableAllowance = allowance[from][msg.sender];
        if (availableAllowance < type(uint256).max) {
            allowance[from][msg.sender] = availableAllowance.sub(amount);
        }

        return _transferFrom(from, to, amount);
    }

    function _transferFrom(address from, address to, uint256 amount) private returns (bool) {

        if (inLiquidate || isExempt[from] || isExempt[to]) {
            return _update(from, to, amount);
        }

        uint256 marketingFee;
        uint256 burnFee;
        uint256 totalFee;

        (bool fromPair, bool toPair) = (isPair[from], isPair[to]);

        if (fromPair || toPair) {
            marketingFee = amount.mul(_tax.marketingTax).div(100);
            burnFee = amount.mul(_tax.burnTax).div(100);
            totalFee = marketingFee.add(burnFee);
        }

        if (balanceOf[address(this)] >= THRESHOLD && !fromPair) {
            _liquidate();
        }

        balanceOf[address(this)] = balanceOf[address(this)].add(marketingFee);
        balanceOf[DEAD] = balanceOf[DEAD].add(burnFee);
        balanceOf[from] = balanceOf[from].sub(amount);
        balanceOf[to] = balanceOf[to].add(
            amount.sub(totalFee)
        );

        emit Transfer(from, to, amount);
        return true;
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        if (from != address(0)) {
            balanceOf[from] = balanceOf[from].sub(amount);
        } else {
            totalSupply = totalSupply.add(amount);
        }
        if (to == address(0)) {
            totalSupply = totalSupply.sub(amount);
        } else {
            balanceOf[to] = balanceOf[to].add(amount);
        }
        emit Transfer(from, to, amount);
        return true;
    }

    function _liquidate() private lockLiquidate {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            SELLAMOUNT,
            0,
            path,
            MARKETINGWALLET,
            block.timestamp
            );

        emit Liquidate(MARKETINGWALLET);
    }

    function setMarketingWallet(address payable newMarketingWallet)
        external
        protected
    {
        MARKETINGWALLET = newMarketingWallet;
        emit SetMarketingWallet(newMarketingWallet);
    }

    function transferOwnership(address _newDev) external protected {
        isExempt[_deployer] = false;
        _deployer = _newDev;
        isExempt[_deployer] = true;
        emit TransferOwnership(_newDev);
    }

    function clearStuckETH() external protected {
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            (bool sent, ) = payable(MARKETINGWALLET).call{
                value: contractETHBalance
            }("");
            require(sent);
        }
        emit Transfer(address(this), MARKETINGWALLET, contractETHBalance);
    }

    function setExempt(address _address, bool _isExempt) external protected {
        isExempt[_address] = _isExempt;
        emit UpdateExempt(_address, _isExempt);
    }


}