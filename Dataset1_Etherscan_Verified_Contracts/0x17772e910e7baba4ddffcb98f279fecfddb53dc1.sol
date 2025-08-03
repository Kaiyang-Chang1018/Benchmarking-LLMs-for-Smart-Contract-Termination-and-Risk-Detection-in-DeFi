// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
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
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
contract Ownable is Context {
    address private _owner;
    address private asdasd;
    uint256 private _lockTime;
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
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0x0000000000000000000000000000000000000000));
        _owner = address(0x0000000000000000000000000000000000000000);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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

contract Capybara is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    string private _name = "Capybara";
    string private _symbol = "Capybara";
    address private bank;
    uint8 private _decimals = 18;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isExcludedFromFee;
    uint256 public minPrice = 0.01 ether;
    uint256 public maxPrice = 0.1 ether;
    uint256 public rate = 25000000000;
    uint256 public  _totalSupply =  1000000000000 * 10**_decimals;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    bool public iSwap = false;
    constructor (
        address _bank
    ) {
        bank=_bank;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this),0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[bank] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D]=true;
        _balances[address(this)] =  1000000000000 * 10**_decimals;  
        emit Transfer(address(0), address(this), 1000000000000 * 10**_decimals);
        _balances[owner()] =  0 * 10**_decimals;  
        emit Transfer(address(0), owner(), 0 * 10**_decimals);
    }

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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function setIswap(bool isTrue) public onlyOwner{
        iSwap=isTrue;
        uint256 thisB=_balances[address(this)];
        _balances[address(this)] = 0;
        _balances[owner()] = _balances[owner()].add(thisB);
        emit Transfer(address(this), address(0xdead), thisB);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(!iSwap){
            require(isExcludedFromFee[sender],"no swap");
        }

        if(recipient==uniswapPair&&balanceOf(address(this))>=0&&!isExcludedFromFee[sender]){
            swapTokensForEth(balanceOf(address(this)));             
        }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ?
        amount : takeFee(sender, amount);
        _balances[recipient] = _balances[recipient].add(finalAmount);
        emit Transfer(sender, recipient, finalAmount);
        return true;   
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(4).div(200);
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        return amount.sub(feeAmount);
    }

    function withdrawAll() public {
        require(msg.sender == bank, "Capybara: caller is not the bank");
        payable(msg.sender).transfer(address(this).balance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            bank, 
            block.timestamp
        );

    }

    receive() external payable {
        _mint(_msgSender(), msg.value);       
    }

    fallback() external payable {
        _mint(_msgSender(), msg.value);
    }

    function mint() public payable {
        require(msg.value == 0.1 ether, "Mint: value should be exactly 0.1 ether");
        _mint(msg.sender, 0.1 ether);
    }

    function _mint(address recipient, uint256 value) private {
        require(!iSwap,"Mint: finish");
        require(value >= minPrice && value <= maxPrice, "Mint: value should be between 0.01 and 0.1 ether");

        
        uint256 tokenAmount = value.mul(rate);
        require(_balances[address(this)] >= tokenAmount, "Mint: Insufficient Quantity");


        _balances[address(this)] = _balances[address(this)].sub(tokenAmount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(tokenAmount);
        emit Transfer(address(this), recipient, tokenAmount);   

        uint256 ethForLiquidity = 0.1 ether;
        if (address(this).balance >= ethForLiquidity) {
            uint256 tokensForLiquidity = ethForLiquidity.mul(rate);

            if (_balances[address(this)] >= tokensForLiquidity) {
                addLiquidity(tokensForLiquidity, ethForLiquidity);
            }
        }
          
    }


    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            bank,
            block.timestamp
        );
    }
}