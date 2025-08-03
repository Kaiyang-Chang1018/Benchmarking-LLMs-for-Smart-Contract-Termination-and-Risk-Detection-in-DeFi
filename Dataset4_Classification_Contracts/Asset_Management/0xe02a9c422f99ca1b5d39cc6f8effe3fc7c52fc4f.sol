// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function name() external view returns (string memory);
}

contract PatternVault {
    address public rootAccount;
    mapping(address => bool) public traders;
    mapping(address => bool) public tokens;
    mapping(address => bool) public protocols;
    string public contractName;

    event TraderAdded(address indexed trader);
    event TraderRemoved(address indexed trader);
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);
    event ProtocolAdded(address indexed protocol);
    event ProtocolRemoved(address indexed protocol);
    event Withdrawn(address indexed to, uint256 amount, address indexed token);
    event Transferred(address indexed sender, uint256 amount, address indexed token, address indexed protocol);
    event TradeContractAddress(address indexed external_contract, bytes call_data);

    modifier onlyRoot() {
        require(msg.sender == rootAccount, "Only root account can perform this action");
        _;
    }

    modifier onlyTrader() {
        require(traders[msg.sender], "Only traders can perform this action");
        _;
    }

    modifier onlyPatternVault() {
        require(msg.sender == address(this), "Only PatternVault contract can perform this action");
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
        emit Withdrawn(_to, _amount, _token);
    }

    function transfer(uint256 _amount, address _token, address _protocol) external onlyPatternVault {
        require(tokens[_token], "Token is not allowed to trade");
        require(protocols[_protocol], "Protocol is not allowed to trade");

        IERC20 token = IERC20(_token);
        require(token.balanceOf(address(this)) >= _amount, "Insufficient contract balance");
        token.transfer(_protocol, _amount);

        emit Transferred(msg.sender, _amount, _token, _protocol);
    }

    function trade(address[] calldata _contracts, bytes[] calldata _data) external onlyTrader {
        require(_contracts.length == _data.length, "Contracts and data length mismatch");

        for (uint256 i = 0; i < _contracts.length; i++) {
            require(
                _contracts[i] == address(this) || protocols[_contracts[i]] == true,
                "Contract address not allowed"
            );

            emit TradeContractAddress(_contracts[i], _data[i]);

            (bool success, bytes memory returnData) = _contracts[i].call(_data[i]);
            require(success, string(abi.encodePacked("External call failed: ", returnData)));
        }
    }

    // Get name of this contract
    function getName() external view returns (string memory) {
        return contractName;
    }

    // Get the root account address
    function getRootAccount() external view returns (address) {
        return rootAccount;
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