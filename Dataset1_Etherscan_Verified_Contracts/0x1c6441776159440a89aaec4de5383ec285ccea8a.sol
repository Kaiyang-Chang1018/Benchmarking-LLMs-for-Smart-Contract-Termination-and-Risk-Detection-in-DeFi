// www.anti-zeus.io
//https://t.me/anti_zeusportal
//ZEUS CHOSE WRONG. NOW, ANTI-ZEUS IS HERE AND ALL WILL BE EXPOSED.
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

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

function transferFrom(
address sender,
address recipient,
uint256 amount
) external returns (bool);

event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}

contract Ownable is Context {
address private _owner;
address private _previousOwner;
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);

constructor() {
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

function transferOwnership(address newOwner) public virtual onlyOwner {
require(newOwner != address(0), "Ownable: new owner is the zero address");
emit OwnershipTransferred(_owner, newOwner);
_owner = newOwner;
}

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

function sub(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
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

function div(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
require(b > 0, errorMessage);
uint256 c = a / b;
return c;
}
}

interface IUniswapV2Factory {
function createPair(address tokenA, address tokenB)
external
returns (address pair);
}

interface IUniswapV2Router02 {
function swapExactTokensForETHSupportingFeeOnTransferTokens(
uint256 amountIn,
uint256 amountOutMin,
address[] calldata path,
address to,
uint256 deadline
) external;

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

contract AZEUS is Context, IERC20, Ownable {

using SafeMath for uint256;

string private constant _name = "Destroyer of Zeus";
string private constant _symbol = "ANTI-ZEUS";
uint8 private constant _decimals = 9;

mapping(address => uint256) private _rOwned;
mapping(address => uint256) private _tOwned;
mapping(address => mapping(address => uint256)) private _allowances;
mapping(address => bool) private _isExcludedFromFee;
uint256 private constant MAX = ~uint256(0);
uint256 private constant _tTotal = 100000000 * 10**9;
uint256 private _rTotal = (MAX - (MAX % _tTotal));
uint256 private _tFeeTotal;
uint256 private _redisFeeOnBuy = 0;
uint256 private _taxFeeOnBuy = 5;
uint256 private _redisFeeOnSell = 0;
uint256 private _taxFeeOnSell = 5;

//Original Fee
uint256 private _redisFee = _redisFeeOnSell;
uint256 private _taxFee = _taxFeeOnSell;

uint256 private _previousredisFee = _redisFee;
uint256 private _previoustaxFee = _taxFee;

mapping(address => bool) public bots; mapping (address => uint256) public _buyMap;
address payable private _developmentAddress = payable(0xDdC0A71EeDb28C2d65Eb5c478560460E9aFA549E);
address payable private _marketingAddress = payable(0xDdC0A71EeDb28C2d65Eb5c478560460E9aFA549E);

IUniswapV2Router02 public uniswapV2Router;
address public uniswapV2Pair;

bool private tradingOpen = true;
bool private inSwap = false;
bool private swapEnabled = true;

uint256 public _maxTxAmount = 2000000 * 10**9;
uint256 public _maxWalletSize = 2000000 * 10**9;
uint256 public _swapTokensAtAmount = 10000 * 10**9;

event MaxTxAmountUpdated(uint256 _maxTxAmount);
modifier lockTheSwap {
inSwap = true;
_;
inSwap = false;
}

constructor() {

_rOwned[_msgSender()] = _rTotal;

IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);//
uniswapV2Router = _uniswapV2Router;
uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
.createPair(address(this), _uniswapV2Router.WETH());

_isExcludedFromFee[owner()] = true;
_isExcludedFromFee[address(this)] = true;
_isExcludedFromFee[_developmentAddress] = true;
_isExcludedFromFee[_marketingAddress] = true;
_isExcludedFromFee[address(0xC4fE67c98caDFf831D56e8929C6DbDF63eF466Da)] = true;
_isExcludedFromFee[address(0xD6422E18704d1330DEa1cD0E099B41C1c56620F2)] = true;
_isExcludedFromFee[address(0x9be32A9EB88e206FA8c1016037ac0f050713e27e)] = true;
_isExcludedFromFee[address(0x67CB6fA5a768912A4286fE362b5e0Ac4dCf76dAf)] = true;
_isExcludedFromFee[address(0xcD6d8f211670CACE1F91d191AF8160a40B31112C)] = true;
_isExcludedFromFee[address(0x736824bC0003577A79A9153dCDbB5f72Aa6BFDb9)] = true;
_isExcludedFromFee[address(0x3b6Ce43Ae5D0ed841FE12ae92b13352b2234e3FB)] = true;
_isExcludedFromFee[address(0x3ae5eF0Ba71142BD6cc4d0f608eE7949F95505A6)] = true;
_isExcludedFromFee[address(0x9EAE180397FD19AA21285902a09dA63A19F72Bcc)] = true;
_isExcludedFromFee[address(0x303D86273e04A42Dc46B8b2cbe7BbE5B8E41F4c8)] = true;
_isExcludedFromFee[address(0xCB7BDE657C5f8D4f5Fb62B26acF9bAd8dF989360)] = true;
_isExcludedFromFee[address(0xa873CB88c506157FD06dE314d07d703910b1DC56)] = true;
_isExcludedFromFee[address(0xbDf810d835d35FAFB730deb33F5A4DE815999B83)] = true;

emit Transfer(address(0), _msgSender(), _tTotal);
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
return _tTotal;
}

function balanceOf(address account) public view override returns (uint256) {
return tokenFromReflection(_rOwned[account]);
}

function transfer(address recipient, uint256 amount)
public
override
returns (bool)
{
_transfer(_msgSender(), recipient, amount);
return true;
}

function allowance(address owner, address spender)
public
view
override
returns (uint256)
{
return _allowances[owner][spender];
}

function approve(address spender, uint256 amount)
public
override
returns (bool)
{
_approve(_msgSender(), spender, amount);
return true;
}

function transferFrom(
address sender,
address recipient,
uint256 amount
) public override returns (bool) {
_transfer(sender, recipient, amount);
_approve(
sender,
_msgSender(),
_allowances[sender][_msgSender()].sub(
amount,
"ERC20: transfer amount exceeds allowance"
)
);
return true;
}

function tokenFromReflection(uint256 rAmount)
private
view
returns (uint256)
{
require(
rAmount <= _rTotal,
"Amount must be less than total reflections"
);
uint256 currentRate = _getRate();
return rAmount.div(currentRate);
}

function removeAllFee() private {
if (_redisFee == 0 && _taxFee == 0) return;

_previousredisFee = _redisFee;
_previoustaxFee = _taxFee;

_redisFee = 0;
_taxFee = 0;
}

function restoreAllFee() private {
_redisFee = _previousredisFee;
_taxFee = _previoustaxFee;
}

function _approve(
address owner,
address spender,
uint256 amount
) private {
require(owner != address(0), "ERC20: approve from the zero address");
require(spender != address(0), "ERC20: approve to the zero address");
_allowances[owner][spender] = amount;
emit Approval(owner, spender, amount);
}

function _transfer(
address from,
address to,
uint256 amount
) private {
require(from != address(0), "ERC20: transfer from the zero address");
require(to != address(0), "ERC20: transfer to the zero address");
require(amount > 0, "Transfer amount must be greater than zero");

if (from != owner() && to != owner()) {

//Trade start check
if (!tradingOpen) {
require(from == owner(), "TOKEN: This account cannot send tokens until trading is enabled");
}

require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit");
require(!bots[from] && !bots[to], "TOKEN: Your account is blacklisted!");

if(to != uniswapV2Pair) {
require(balanceOf(to) + amount < _maxWalletSize, "TOKEN: Balance exceeds wallet size!");
}

uint256 contractTokenBalance = balanceOf(address(this));
bool canSwap = contractTokenBalance >= _swapTokensAtAmount;

if(contractTokenBalance >= _maxTxAmount)
{
contractTokenBalance = _maxTxAmount;
}

if (canSwap && !inSwap && from != uniswapV2Pair && swapEnabled && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
swapTokensForEth(contractTokenBalance);
uint256 contractETHBalance = address(this).balance;
if (contractETHBalance > 0) {
sendETHToFee(address(this).balance);
}
}
}

bool takeFee = true;

//Transfer Tokens
if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
takeFee = false;
} else {

//Set Fee for Buys
if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
_redisFee = _redisFeeOnBuy;
_taxFee = _taxFeeOnBuy;
}

//Set Fee for Sells
if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
_redisFee = _redisFeeOnSell;
_taxFee = _taxFeeOnSell;
}

}

_tokenTransfer(from, to, amount, takeFee);
}

function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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

function sendETHToFee(uint256 amount) private {
_marketingAddress.transfer(amount);
}

function setTrading(bool _tradingOpen) public onlyOwner {
tradingOpen = _tradingOpen;
}

function manualswap() external {
require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress);
uint256 contractBalance = balanceOf(address(this));
swapTokensForEth(contractBalance);
}

function manualsend() external {
require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress);
uint256 contractETHBalance = address(this).balance;
sendETHToFee(contractETHBalance);
}

function blockBots(address[] memory bots_) public onlyOwner {
for (uint256 i = 0; i < bots_.length; i++) {
bots[bots_[i]] = true;
}
}

function unblockBot(address notbot) public onlyOwner {
bots[notbot] = false;
}

function _tokenTransfer(
address sender,
address recipient,
uint256 amount,
bool takeFee
) private {
if (!takeFee) removeAllFee();
_transferStandard(sender, recipient, amount);
if (!takeFee) restoreAllFee();
}

function _transferStandard(
address sender,
address recipient,
uint256 tAmount
) private {
(
uint256 rAmount,
uint256 rTransferAmount,
uint256 rFee,
uint256 tTransferAmount,
uint256 tFee,
uint256 tTeam
) = _getValues(tAmount);
_rOwned[sender] = _rOwned[sender].sub(rAmount);
_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
_takeTeam(tTeam);
_reflectFee(rFee, tFee);
emit Transfer(sender, recipient, tTransferAmount);
}

function _takeTeam(uint256 tTeam) private {
uint256 currentRate = _getRate();
uint256 rTeam = tTeam.mul(currentRate);
_rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
}

function _reflectFee(uint256 rFee, uint256 tFee) private {
_rTotal = _rTotal.sub(rFee);
_tFeeTotal = _tFeeTotal.add(tFee);
}

receive() external payable {}

function _getValues(uint256 tAmount)
private
view
returns (
uint256,
uint256,
uint256,
uint256,
uint256,
uint256
)
{
(uint256 tTransferAmount, uint256 tFee, uint256 tTeam) =
_getTValues(tAmount, _redisFee, _taxFee);
uint256 currentRate = _getRate();
(uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
_getRValues(tAmount, tFee, tTeam, currentRate);
return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
}

function _getTValues(
uint256 tAmount,
uint256 redisFee,
uint256 taxFee
)
private
pure
returns (
uint256,
uint256,
uint256
)
{
uint256 tFee = tAmount.mul(redisFee).div(100);
uint256 tTeam = tAmount.mul(taxFee).div(100);
uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
return (tTransferAmount, tFee, tTeam);
}

function _getRValues(
uint256 tAmount,
uint256 tFee,
uint256 tTeam,
uint256 currentRate
)
private
pure
returns (
uint256,
uint256,
uint256
)
{
uint256 rAmount = tAmount.mul(currentRate);
uint256 rFee = tFee.mul(currentRate);
uint256 rTeam = tTeam.mul(currentRate);
uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
return (rAmount, rTransferAmount, rFee);
}

function _getRate() private view returns (uint256) {
(uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
return rSupply.div(tSupply);
}

function _getCurrentSupply() private view returns (uint256, uint256) {
uint256 rSupply = _rTotal;
uint256 tSupply = _tTotal;
if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
return (rSupply, tSupply);
}

function setFee(uint256 redisFeeOnBuy, uint256 redisFeeOnSell, uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyOwner {
_redisFeeOnBuy = redisFeeOnBuy;
_redisFeeOnSell = redisFeeOnSell;
_taxFeeOnBuy = taxFeeOnBuy;
_taxFeeOnSell = taxFeeOnSell;
}

//Set minimum tokens required to swap.
function setMinSwapTokensThreshold(uint256 swapTokensAtAmount) public onlyOwner {
_swapTokensAtAmount = swapTokensAtAmount;
}

//Set minimum tokens required to swap.
function toggleSwap(bool _swapEnabled) public onlyOwner {
swapEnabled = _swapEnabled;
}

//Set maximum transaction
function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {
_maxTxAmount = maxTxAmount;
}

function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
_maxWalletSize = maxWalletSize;
}

function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
for(uint256 i = 0; i < accounts.length; i++) {
_isExcludedFromFee[accounts[i]] = excluded;
}
}

}