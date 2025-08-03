// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);

}

contract Xitcoin_Bridge_Contract {
    IERC20 public immutable token;
    address public admin;
    mapping(bytes32 => bool) public processedTransactions;
    mapping(uint256=> bool) public supportedChain;
    address private companyWallet;
    address private relayer;
    uint256 private rate;

    event TokensLocked(address indexed user, uint256 amount, uint256 destinationChainId, address destinationAddress);
    event TokensUnlocked(address indexed user, uint256 amount, bytes32 indexed txHash);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    modifier  onlyRelayer(){
                require(msg.sender == relayer, "Not authorized");
        _;
    }

    constructor(address _tokenAddress, address _companyWallet,address _relayer, uint256 _rate) {
        token = IERC20(_tokenAddress);
        admin = msg.sender;
        companyWallet = _companyWallet;
        relayer = _relayer;
        rate = _rate;
    }
    


    function lockTokens(uint256 amount, uint256 sourceChainId, uint256 destinationChainId, address destinationAddress) external payable {
        require(supportedChain[sourceChainId]);
        require(supportedChain[destinationChainId], 'Chain not supported');
        require(msg.value > 0, "Fee must be paid in Ether");
        uint256 tax = (rate * amount) / 100000;
        require(msg.value >= tax, "Insufficient fee paid");
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        payable(companyWallet).transfer(tax);

        emit TokensLocked(msg.sender, amount, destinationChainId, destinationAddress);
    }

    /**
 
     *  txHash Unique transaction hash from the source chain.
     */
    function unlockTokens(address user,uint256 destinationChainId, uint256 amount, bytes32 txHash) external onlyRelayer {
        require(supportedChain[destinationChainId]);
        require(!processedTransactions[txHash], "Transaction already processed");
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance");

        processedTransactions[txHash] = true;
        require(token.transfer(user, amount), "Transfer failed");
        emit TokensUnlocked(user, amount, txHash);
    }

    /**
     *  Withdraw mistakenly sent tokens (admin only).

     */
    function withdrawExcessTokens(uint256 amount) external onlyAdmin {
        require(token.transfer(admin, amount), "Withdraw failed");
    }

    function changeCompanyWallet(address _companyWallet) external onlyAdmin {
        companyWallet = _companyWallet;
    }

    function changeRate(uint256 _rate) external onlyAdmin {
        rate = _rate;
    }

    /**
     * @dev Change the admin address (in case of relayer key rotation).
     */
    function updateAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }

    function addSupportedChain(uint256 chainId) external onlyAdmin{
        supportedChain[chainId] = true;
    }

    function removeSupportedChain(uint256 chainId) external onlyAdmin{
        supportedChain[chainId] = false;
    }

    function changeRelayerAddress(address _relayer) external onlyRelayer{
        relayer = _relayer;
    }

}