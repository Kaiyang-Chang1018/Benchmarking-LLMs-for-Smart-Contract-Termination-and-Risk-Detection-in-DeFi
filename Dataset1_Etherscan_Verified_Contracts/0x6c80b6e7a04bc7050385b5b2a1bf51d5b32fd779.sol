/**
// SPDX-License-Identifier: MIT
/** 
https://t.me/GoomerCoin
https://twitter.com/GoomerCoin
                                                                                                                                                                    
                                   .^: .:^!7?JJYYY5555Y5PGGGGBGGGP~.                                
                               .^~J#B#GG#@@##&B&#BB@@@#B#B##B#B#B&@#P?.                             
                            .~G&&&@BG#@5#@@#&&#&#BG#BBGB#B#&#&@&#&@G@@B?.                           
                         :7P#&G#&GB####GPPYJYP55J555Y7Y555?YPG5B&@&#@@@@#7                          
                     .!YB&@BPBB&#GGG5?~^    .~!?7Y5YY55Y?:~^.^YJPB@@@@@@@@B~                        
                    ~&@@@@@&&@&?!??7^          ^7?YJJY7^.     .7?75P&@@@@@@@Y.                      
                    ~@@@@@@@@P~.       . .~.      .:^.          ..  ~P&@@@@@@G                      
                    !@@@@@@@J          .  .  .:::                     !&@@@@@@^                     
                    7@@@@@@5 .~  .^:::^^^^^^^^::^~^^^^^::::::^.   ::  .5#@@@@@P                     
                    P@@@@@G:    . :^^^^^^~~^^^^^^^::::::^^^:::.   ..   :P@@@@@@?                    
              ..   :&@@@@&7    .. .::::........:^^^^:::::::^^^^^     .. :#@@@@@B                    
            ?G#BPPG#@@@@@@P            .::^^~~~^^:^^~^^::::::::::....:.  P#@@@@@^                   
            B@@@#BBBB&@@@P.^.    .^^^^^^^:...        .......::::::::.:.. !&@@@@@~                   
            B@@5YJJJJJB@G. :   .^..::^::::7:             ^^^^^~^^^:..     P@@@@@#BP5YY?~.           
            P@BYPJYYYJB@7     ^!~~^^::::::^.           :.::.....::^!^.    Y@@@GY55PG&@@@?           
            ?@#GBBB###@&:     .            ^~.       .!~.        ...^.    !&@@BJJJJJYYB@!           
            :&@@@@@@@@@B.     ^?7!!~^::.    ^:       .: .^~~!?YPPJ5P:     ~@@@GJYYJ5PYGB            
             B@@@@@@@@@B.     .YJ?#@&&&GJ7!.           :Y?7G@@@@@J!P      ~@@@#GBGGGGB@J            
             G@@@@@@@@@@J     ^^7?P#BBBJJP5.           :P5YGB#&&#J?P.     J&@@@@@@@@@@&^            
             5@@@&&&&&&&G.    ^?YGPP5555Y~   .          :JYJ?J?7YP5?.    ~#@@@@@@@@@@@#.            
             J@P5YY5YYYP&J!7    .!~:~!77J!7:  7:     ^~  :!?JJJ~~!!~: .^^G@@@@@@@@@@@@#.            
             J@YJJYYJJJB@BJJ7!   ~JJY5555J^..~5.     ~5.   .~7?77?!:  ?&5P@@BGGGB##B&@#.            
             J@#YPPYY5YG@@&??~ .    ..::::~7YJ^       7?~.........   .Y&#P&@BJJJJJY55@#.            
            .B@@&##&&&&@@@@#5~JJ.    .^~~~?~:  :.  :: .:!7!:^~^. .. .G#@&B&@&Y55JJYBJ&G             
            .^~7?JJJJ?77P#@BGGG^  .:~~:. .J^  ~Y:  :: ^. JJ  :~?:....#@@@##@&###BGGGG&G             
                        Y#&P&#5?~~!!~:^~.:!?~::^:....:::?J::~^.^!::.!&@@@G^J!!7!Y@@#55!             
                        !&##&GGBG#BGG5PPJ???J??J7~!7?J?7J??JJ5!JGJJP&@@@@B7     .&@#:               
                        7G5G&&@&##&&##P?G7J5~J7~!~77J?JYYYPP!~~YGGJ&@&&@&B:     .&@@:               
                        .7P##&@BB&@@&#5PY!YY~7?YJY75Y~PJJ7?:~??J#&&#&&&BP?      ?@@&:               
                         :J?JG#&&#BB&##GJ?!Y!77??Y7Y?~?!~^.:5BBB&&#&&&G!7~     !@@@G                
                          .  !GG#BB&@&BGP&PJ!!^^~!^^~^.^~.7JB&5B&B#&&@G:  .^..?&@@&!                
                              ~?GG@@&&GB#@#BGYGP5Y?J?P?5P5G5##5P&G##YPJ!^?55PB@@&P~                 
                                P@BGB&&5B##GB5#5BGBBY&&GG###P##PGYBJ  .J?&GY5BBGP~                  
                                !Y~PGGBB&GBBBP#P###G#&#BB&#GPGP&?.^   .5P#YJ5J5?^.                  
                                   5~.:75B#BGP&PGY5PPGB#PG&5P5?B.      :77?~~^.                     
                                  .G:   :????J555YJ5J?PPYJ7::^.B7        ..                         
                                  ~G.         J5Y775?Y?~      .#P           


**/

pragma solidity 0.8.20;

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

contract GOOMER is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = true;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=20;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=25;
    uint256 private _reduceSellTaxAt=30;
    uint256 private _preventSwapBefore=25;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"GOOMER";
    string private constant _symbol = unicode"GOOMER";
    uint256 public _maxTxAmount = 10000000 * 10**_decimals;
    uint256 public _maxWalletSize = 10000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 14000001 * 10**_decimals;
    uint256 public _maxTaxSwap= 14000000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

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
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (transferDelayEnabled) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                      require(
                          _holderLastTransferTimestamp[tx.origin] <
                              block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 50000000000000000) {
                    sendETHToFee(address(this).balance);
                }
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
        transferDelayEnabled=false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }


    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
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
}