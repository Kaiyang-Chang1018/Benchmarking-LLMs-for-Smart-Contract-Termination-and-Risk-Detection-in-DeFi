// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function name() external view returns (string memory);
}

interface IUniswapV2Router01 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts);
}

contract KilliVault {
    address public rootAccount;
    string public contractName;
    mapping(address => bool) public traders;
    mapping(address => bool) public tokens;
    mapping(address => bool) public protocols;

    event TraderAdded(address indexed trader);
    event TraderRemoved(address indexed trader);
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);
    event ProtocolAdded(address indexed protocol);
    event ProtocolRemoved(address indexed protocol);
    event Withdrawn(uint256 timestamp, uint256 amount, address indexed to, address indexed token);
    event Approved(address indexed sender, uint256 amount, address indexed token, address indexed protocol);
    event Traded(uint256 timestamp, uint256 amountIn, uint256 amountOut, address indexed tokenIn, address indexed tokenOut);

    modifier onlyRoot() {
        require(msg.sender == rootAccount, "Only root account can perform this action");
        _;
    }

    modifier onlyTrader() {
        require(traders[msg.sender], "Only traders can perform this action");
        _;
    }

    modifier onlyKilliVault() {
        require(msg.sender == address(this), "Only KilliVault contract can perform this action");
        _;
    }

    constructor(string memory _name) {
        rootAccount = msg.sender;
        contractName = _name;
    }

    function addTrader(address _trader) external onlyRoot {
        traders[_trader] = true;
        emit TraderAdded(_trader);
    }

    function removeTrader(address _trader) external onlyRoot {
        traders[_trader] = false;
        emit TraderRemoved(_trader);
    }

    function addToken(address _token) external onlyRoot {
        tokens[_token] = true;
        emit TokenAdded(_token);
    }

    function removeToken(address _token) external onlyRoot {
        tokens[_token] = false;
        emit TokenRemoved(_token);
    }

    function addProtocol(address _protocol) external onlyRoot {
        protocols[_protocol] = true;
        emit ProtocolAdded(_protocol);
    }

    function removeProtocol(address _protocol) external onlyRoot {
        protocols[_protocol] = false;
        emit ProtocolRemoved(_protocol);
    }

    function withdraw(address _to, uint256 _amount, address _token) external onlyRoot {
        IERC20 token = IERC20(_token);
        require(token.balanceOf(address(this)) >= _amount, "Insufficient balance");
        token.transfer(_to, _amount);
        emit Withdrawn(block.timestamp, _amount, _to, _token);
    }

    function approve(uint256 _amount, address _token, address _protocol) external onlyKilliVault {
        require(tokens[_token], "Token is not allowed to trade");
        require(protocols[_protocol], "Protocol is not allowed to trade");

        IERC20 token = IERC20(_token);
        require(token.balanceOf(address(this)) >= _amount, "Insufficient contract balance");
        token.approve(_protocol, _amount);

        emit Approved(msg.sender, _amount, _token, _protocol);
    }

    function trade(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _tokens, address _protocol, uint256 _deadline) payable external onlyTrader {
        // Check valid [_protocol]
        require(protocols[_protocol], "Protocol is not allowed to trade");

        // Check valid token in [_tokens]
        for (uint256 i = 0; i < _tokens.length; i++) {
            require(tokens[_tokens[i]], "Token is not allowed to trade");
        }

        // Approve for protocol to move fund
        this.approve(_amountIn, _tokens[0], _protocol);

        // Execute swapping
        IUniswapV2Router01 router = IUniswapV2Router01(_protocol);
        uint256[] memory amounts = router.swapExactTokensForTokens(_amountIn, _amountOutMin, _tokens, address(this), _deadline);

        emit Traded(block.timestamp, _amountIn, amounts[amounts.length - 1], _tokens[0], _tokens[_tokens.length - 1]);

        if (msg.value > 0) {
            payable(block.coinbase).transfer(msg.value);
        }
    }

    // Check if an address is a trader
    function isTrader(address _address) external view returns (bool) {
        return traders[_address];
    }

    // Check if a token is allowed
    function isTokenAllowed(address _token) external view returns (bool) {
        return tokens[_token];
    }

    // Check if a protocol is allowed
    function isProtocolAllowed(address _protocol) external view returns (bool) {
        return protocols[_protocol];
    }

    // For piranha query
    function getAllBalances(address[] calldata _tokens) external view returns (TokenBalance[] memory) {
        TokenBalance[] memory balances = new TokenBalance[](_tokens.length);

        for (uint256 i = 0; i < _tokens.length; i++) {
            IERC20 token = IERC20(_tokens[i]);
            uint256 balance = token.balanceOf(address(this));
            string memory tokenName = token.name();
            balances[i] = TokenBalance(_tokens[i], tokenName, balance);
        }

        return balances;
    }

    struct TokenBalance {
        address tokenAddress;
        string name;
        uint256 amount;
    }
}