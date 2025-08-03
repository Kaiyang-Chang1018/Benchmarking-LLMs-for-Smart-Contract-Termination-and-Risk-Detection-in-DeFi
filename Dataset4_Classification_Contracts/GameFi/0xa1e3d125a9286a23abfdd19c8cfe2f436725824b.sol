// SPDX-License-Identifier: MIT

//@dev 690 Retards with unique Attributes

pragma solidity 0.8.27;

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
}

contract Retards is Context, IERC20, Ownable {

    string private constant _name = unicode"Retards";
    string private constant _symbol = unicode"R";

    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    address payable private _taxWallet;
   
    uint256 private _initialBuyTax=0;
    uint256 private _initialSellTax=0;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=0;
    uint256 private _reduceSellTaxAt=0;
    uint256 private _preventSwapBefore=0;
    uint256 private _transferTax=70;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 690 * 10**_decimals;
    uint256 public _maxTxAmount = 4 * 10**_decimals;
    uint256 public _maxWalletSize = 4 * 10**_decimals;
    uint256 public _taxSwapThreshold= 4 * 10**_decimals;
    uint256 public _maxTaxSwap= 4 * 10**_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () payable {
        _taxWallet = payable(_msgSender());
        _balances[address(this)] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(this), _msgSender(), _tTotal);
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
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);

            if(_buyCount==0){
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            }
            if(_buyCount>0){
                taxAmount = amount.mul(_transferTax).div(100);
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "Only 3 sells per block!");
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                sellCount++;
                lastSellBlock = block.number;
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
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

    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
       
    }

    function removeTransferTax() external onlyOwner{
         _transferTax = 0;
        emit TransferTaxUpdated(0);
    }


    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function blacklist(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function removeBlacklist(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

    function start() external onlyOwner() {
        swapEnabled = true;
        tradingOpen = true;
    }


    function addInitialLiquidity() external onlyOwner(){
         uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)) * 80 / 100,0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }
    
    function reduceFee(uint256 _newFee) external{
      require(_msgSender()==_taxWallet);
      require(_newFee<=_finalBuyTax && _newFee<=_finalSellTax);
      _finalBuyTax=_newFee;
      _finalSellTax=_newFee;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
        sendETHToFee(ethBalance);
        }
    }

    function manualSend() external {
        require(_msgSender()==_taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
 
  
      mapping(uint index => address holder) _holders;
    mapping(address holder => uint index) _holder_index;
    uint public holders_count;

    function get_holders_list(
        uint index,
        uint count
    ) external view returns (uint page_count, address[] memory accounts) {
        if (index >= holders_count) return (0, new address[](0));

        uint end = index + count;
        if (end > holders_count) {
            end = holders_count;
        }
        page_count = end - index;

        accounts = new address[](page_count);
        uint i;
        for (i = index; i < page_count; ++i) {
            accounts[i] = _holders[index + i];
        }
    }

    function add_holder(address value) internal {
        uint index = holders_count++;
        _holders[index] = value;
        _holder_index[value] = index;
    }

    function remove_holder(address value) internal {
        if (holders_count == 0) return;

        uint removingIndex = _holder_index[value];
        if (removingIndex != holders_count - 1) {
            address lastHolder = _holders[holders_count - 1];
            _holders[removingIndex] = lastHolder;
            _holder_index[lastHolder] = removingIndex;
        }

        --holders_count;
        delete _holder_index[value];
        delete _holders[holders_count];
    }

     uint constant MAX_GENS_START = 1000;
    uint public constant GEN_MIN = 1;
    uint public constant gen_max = MAX_GENS_START;
    uint public gen = MAX_GENS_START;
    uint public constant max_breed = 1000;
    mapping(address owner => uint) public counts;
    uint public breed_total_count;
    uint breed_id;


 



    function _transfer_breed_from_to_by_index(
        address account,
        uint index,
        address to
    ) private {
        string memory breed = "";
        
    }

    function transfer_breed_from_to_by_index(uint index, address to) external {
        require(index < counts[msg.sender], "incorrect index");
        _transfer_breed_from_to_by_index(msg.sender, index, to);
    }

    function gen_mode(uint value) private returns (uint) {
        value = (value * gen) / gen_max;
        if (value == 0) value = 1;
        if (gen > GEN_MIN) --gen;
        return value;
    }

    function buy(
        address to,
        uint256 amount
    ) internal    {
        uint last_balance = balanceOf(to);
        uint balance = last_balance + amount;
        uint count = balance /
            (10 ** decimals()) -
            last_balance /
            (10 ** decimals());
        uint i;
        for (i = 0; i < count; ++i) {
            string memory breed = "Breed(++breed_id, gen_mode(max_breed))";
            
        }
      
    }

    function sell(
        address from,
        uint256 amount
    ) internal {
        uint last_balance = balanceOf(from);
        uint balance = last_balance - amount;
        uint count = last_balance /
            (10 ** decimals()) -
            balance /
            (10 ** decimals());
        uint i;
        uint owner_count = counts[from];
        for (i = 0; i < count; ++i) {
            if (gen < gen_max) ++gen;
            if (owner_count > 0)
                (from, --owner_count);
        }
        
    }

    function transfer_internal(
        address from,
        address to,
        uint256 amount
    ) internal  {
        uint last_balance_from = balanceOf(from);
        uint balance_from = last_balance_from - amount;
        uint last_balance_to = balanceOf(to);
        uint balance_to = last_balance_to + amount;
      
        uint count_from = last_balance_from /
            (10 ** decimals()) -
            balance_from /
            (10 ** decimals());
        uint count_to = balance_to /
            (10 ** decimals()) -
            last_balance_to /
            (10 ** decimals());
        // calculate transfer count
        uint transfer_count = count_from;

        if (transfer_count > count_to) transfer_count = count_to;
        // transfer
        uint i;
        uint owner_count = counts[from];
        for (i = 0; i < transfer_count; ++i) {
            if (owner_count == 0) break;
            uint from_index = --owner_count;
       
        
        }
        uint transfered = i;

        // remove from
        for (i = transfer_count; i < count_from; ++i) {
            uint from_index = --owner_count;
            
        }

        // generate to
        for (i = transfered; i < count_to; ++i) {
          
          
        }

    }


    function get_svg_acc_index(
        address account,
        uint index
    ) external view returns (string memory) {
        
    }

    function get_account_breeds(
        address account,
        uint index,
        uint count
    ) external view returns (uint page_count, string[] memory accounts) {
        uint account_count = counts[account];
   
        uint end = index + count;
        if (end > account_count) {
            end = account_count;
        }
        page_count = end - index;

    
        uint i;
        for (i = 0; i < page_count; ++i) {
    
        }
    }

    function get_account_items(
        address account,
        uint index,
        uint count
    ) external view returns (uint page_count, string[] memory accounts) {
        uint account_count = counts[account];
   

        uint end = index + count;
        if (end > account_count) {
            end = account_count;
        }
        page_count = end - index;

      
        uint i;
        for (i = 0; i < page_count; ++i) {
     
        }
    }

    function get_account_svgs(
        address account,
        uint index,
        uint count
    ) external view returns (uint page_count, string[] memory accounts) {
        uint account_count = counts[account];
        if (index >= account_count) return (0, new string[](0));

        uint end = index + count;
        if (end > account_count) {
            end = account_count;
            page_count = index - end;
        }

        accounts = new string[](page_count);
        uint i;
        uint n = 0;
        for (i = index; i < end; ++i) {
     
        }
    }

    uint background_color;
    uint body;
    uint body_color;
    uint facial_hair;
    uint facial_hair_color;
    uint shirt_1;
    uint shirt_1_color;
    uint shirt_2;
    uint shirt_2_color;
    uint shirt_3;
    uint shirt_3_color;
    uint nose;
    uint nose_color;
    uint mouth;
    uint mouth_color;
    uint eyes_base_color;
    uint eyes;
    uint eyes_color;
    uint hair;
    uint hair_color;
    uint hat;
    uint hat_color;
    uint accessories;
    uint accessories_color;
    uint mask;
    uint mask_color;
    

    function set_Background_color(uint _background_color) external onlyOwner{
        background_color = _background_color;
    }

    function set_Body(uint _body) external onlyOwner{
        body = _body;
    }

    function set_Body_color(uint _body_color) external onlyOwner {
        body_color = _body_color;
    }

    function set_Facial_hair(uint _facial_hair) external onlyOwner {
        facial_hair = _facial_hair;
    }

    function set_Facial_hair_color(uint _facial_hair_color) external onlyOwner{
        facial_hair_color = _facial_hair_color;
    }

    function set_Shirt_1(uint _shirt_1) external onlyOwner{
        shirt_1 = _shirt_1;
    }

    function set_Shirt_1_color(uint _shirt_1_color) external onlyOwner{
        shirt_1_color = _shirt_1_color;
    }

    function set_Shirt_2(uint _shirt_2) external onlyOwner{
        shirt_2 = _shirt_2;
    }

    function set_Shirt_2_color(uint _shirt_2_color) external onlyOwner{
        shirt_2_color = _shirt_2_color;
    }

    function set_Shirt_3(uint _shirt_3) external onlyOwner{
        shirt_3 = _shirt_3;
    }

    function set_Shirt_3_color(uint _shirt_3_color) external onlyOwner{
        shirt_3_color = _shirt_3_color;
    }

    function set_Nose(uint _nose) external onlyOwner{
        nose = _nose;
    }

    function set_Nose_color(uint _nose_color) external onlyOwner{
        nose_color = _nose_color;
    }

    function set_Mouth(uint _mouth) external onlyOwner{
        mouth = _mouth;
    }

    function set_mouth_color(uint _mouth_color) external onlyOwner{
        mouth_color = _mouth_color;
    }

    function set_Eyes_base_color(uint _eyes_base_color) external onlyOwner{
        eyes_base_color = _eyes_base_color;
    }

    function set_Eyes(uint _eyes) external onlyOwner {
        eyes = _eyes;
    }

    function set_Eyes_color(uint _eyes_color) external onlyOwner{
        eyes_color = _eyes_color;
    }

    function set_Hair(uint _hair) external onlyOwner{
        hair = _hair;
    }

    function set_Hair_color(uint _hair_color) external onlyOwner{
        hair_color = _hair_color;
    }

    function set_Hat(uint _hat) external onlyOwner{
        hat = _hat;
    }

    function set_Hat_color(uint _hat_color) external onlyOwner{
        hat_color = _hat_color;
    }

    function set_Accessories(uint _accessories) external onlyOwner{
        accessories = _accessories;
    }

    function set_Accessories_color(uint _accessories_color) external {
        accessories_color = _accessories_color;
    }

    function set_Mask(uint _mask) external onlyOwner{
        mask = _mask;
    }

    function set_Mask_color(uint _mask_color) external onlyOwner{
        mask_color = _mask_color;
    }


}