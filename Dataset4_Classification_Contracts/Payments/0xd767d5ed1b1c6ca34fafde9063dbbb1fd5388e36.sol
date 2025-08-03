// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
// SPDX-License-Identifier: MIT

/*
    ERC41 is a new ERC standard that allows the users to create and train their own AI Agents.
    These AI Agents are stored on the blockchain within this smart contract and can be accessed through the available functions.
    Any user/smart contract can deploy and use an AI Agent.

    Website:    https://erc41.ai/
    Twitter:    https://x.com/ERC_41/
    Medium:     https://medium.com/@erc41token/unlocking-ai-agents-on-the-blockchain-introducing-erc-41-ercai-795ad8397e4d/
    Telegram:   https://t.me/ERC_AI
*/

pragma solidity 0.8.28;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/* *
   * @dev ReentrancyGuard is a contract module that helps prevent reentrant calls to a function.
*/
abstract contract ERC41 is ReentrancyGuard {

    using Counters for Counters.Counter; // @notice initializing the Counters library by openzeppelin.

    // @notice Every agent's structure.
    struct Agent { 
        address creator; // @notice The creator of the Agent.
        string name; // @notice The name of the Agent. (unique identifier)
        string training; // @notice The training of the Agent. It will answer based on this training.
        uint256 conversations; // @notice The number of conversations a specific agent had.
    }

    Counters.Counter private agentsCount; // @notice Counter of the agents.
    mapping(string => Agent) private agents; // @notice Storage with all the agents.

    uint256 private constant MIN_NAME_LENGTH = 2; // @notice Minimum characters for every agent name.

    event AgentDeployed(address creator, string name, string training); // @notice This event is triggered when a new agent is deployed.
    event AgentRetrained(address creator, string name, string newTraining); // @notice This event is triggered when an user changes the training of his agent.
    event TalkToAgent(address user, string name, string message); // @notice This event is triggered when an user talks to an agent.
    event AgentTransfered(address creator, address receiver); // @notice This event is triggered when an user transfers his agent to another address.

    /*
    @dev This function is used to retrieve how many agents are stored on the blockchain.
    @return The amount of agents stored on the blockchain.
    */
    function getAgentsCount() public view returns (uint256) {
        return agentsCount.current();
    }

    /*
    @dev This function is used to retrieve the minimum available length for an agent's name.
    @return The minimum length.
    */
    function getMinNameLength() public pure returns (uint256) {
        return MIN_NAME_LENGTH;
    }

    /*
    @dev This function is used to retrieve an agent based on the name.
    @param name The name to search for.
    @return The name if the agent exists or revert.
    */
    function getAgentByName(string calldata name) public view returns (Agent memory) {
        require(bytes(agents[name].name).length != 0, "ERC41: Agent not found.");
        return agents[name];
    }

    /*
    @dev This function is used to retrieve an agent's training.
    @param name The name to search for.
    @return The training of the agent.
    */
    function getAgentTraining(string calldata name) public view returns (string memory) {
        require(bytes(agents[name].name).length != 0, "ERC41: Agent not found.");
        return agents[name].training;
    }

    /*
    @dev This function is used to retrieve an agent's creator.
    @param name The name to search for.
    @return The creator of the agent.
    */
    function getAgentCreator(string calldata name) public view returns (address) {
        require(bytes(agents[name].name).length != 0, "ERC41: Agent not found.");
        return agents[name].creator;
    }

    /*
    @dev This function is used to retrieve an agent's number of conversations.
    @param name The name to search for.
    @return The number of conversations of the agent.
    */
    function getAgentConversations(string calldata name) public view returns (uint256) {
        require(bytes(agents[name].name).length != 0, "ERC41: Agent not found.");
        return agents[name].conversations;
    }

    /*
    @dev This function is used to check whether an agent exists based on the name.
    @param name The name to check for.
    @return True if the agent exists or False if not.
    */
    function existsAgent(string calldata name) public view returns (bool) {
        return (bytes(agents[name].name).length > 0);
    }

    /*
    @dev This function is used to generate, deploy and train a new agent.
    @param name The name of the new agent.
    @param training The training of the new agent.
    @return True if the agent exists or False if not.
    */
    function deployAgent(string calldata name, string calldata training) external returns (Agent memory) {
        require(!existsAgent(name), "ERC41: This agent name already exists.");
        require(bytes(name).length >= MIN_NAME_LENGTH, "ERC41: Invalid name.");

        agents[name] = Agent({
            creator: msg.sender,
            name: name,
            training: training,
            conversations: 0
        });
        emit AgentDeployed(msg.sender, name, training);

        agentsCount.increment();

        return agents[name];
    }

    /*
    @dev This function is used to change the training of an agent.
    @param name The name of the agent.
    @param newTraining The new training of the agent.
    @return True if the agent exists or False if not.
    */
    function trainAgent(string calldata name, string calldata newTraining) external returns (Agent memory) {
        require(existsAgent(name), "ERC41: This agent does not exist.");
        require(agents[name].creator == msg.sender, "ERC41: You are not the creator of this agent.");

        agents[name].training = newTraining;
        emit AgentRetrained(msg.sender, name, newTraining);

        return agents[name];
    }

    /*
    @dev This function is used to talk to an agent.
    @param name The name of the agent.
    @param message The message sent to the agent.
    */
    function talkToAgent(string calldata name, string calldata message) external payable {
        require(msg.value >= 0.002 ether, "ERC41: Not enough ETH sent.");
        require(existsAgent(name), "ERC41: This agent does not exist.");

        agents[name].conversations++;

        emit TalkToAgent(msg.sender, name, message);
    }

    /*
    @dev This function is used to transfer an agent to another address.
    @param name The name of the agent.
    @param receiver The address that receives the agent.
    */
    function transferAgent(string calldata name, address receiver) external {
        require(existsAgent(name), "ERC41: This agent does not exist.");
        require(agents[name].creator == msg.sender, "ERC41: You are not the creator of this agent.");

        agents[name].creator = receiver;

        emit AgentTransfered(msg.sender, receiver);
    }
}
// SPDX-License-Identifier: MIT

/*
    ERC41 is a new ERC standard that allows the users to create and train their own AI Agents.
    These AI Agents are stored on the blockchain within this smart contract and can be accessed through the available functions.
    Any user/smart contract can deploy and use an AI Agent.

    Website:    https://erc41.ai/
    Twitter:    https://x.com/ERC_41/
    Medium:     https://medium.com/@erc41token/unlocking-ai-agents-on-the-blockchain-introducing-erc-41-ercai-795ad8397e4d/
    Telegram:   https://t.me/ERC_AI
*/

pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ERC41.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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

contract ERCAI is ERC41, Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;

    uint256 private _initialBuyTax = 17;
    uint256 private _initialSellTax = 19;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 25;
    uint256 private _reduceSellTaxAt = 25;
    uint256 private _preventSwapBefore = 1;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;

    string private constant _name = unicode"ERC AI";
    string private constant _symbol = unicode"ERC41";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000 * 10**_decimals;
    uint256 public _maxTxAmount = 20000 * 10**_decimals;
    uint256 public _maxWalletSize = 20000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 10000 * 10**_decimals;
    uint256 public _maxTaxSwap= 10000 * 10**_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    uint256 private firstBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    event ClearToken(address TokenAddressCleared, uint256 Amount);
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
        uint256 taxAmount= 0;
        if (from != owner() && to != owner()) {

            if(_buyCount == 0){
                taxAmount = amount.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100);
            }

            if(_buyCount > 0){
                taxAmount = amount.mul(_transferTax).div(100);
            }

            if(block.number == firstBlock){
                require(_buyCount < 40, "Exceeds buys on the first block.");
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100);
                _buyCount++;
            }

            if(to == uniswapV2Pair && from != address(this) ){
                taxAmount= amount.mul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount= 0;
                }
                require(sellCount < 4);

                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }

                sellCount++;
                lastSellBlock = block.number;
            }
        }

        if(taxAmount > 0){
          _balances[address(this)] = _balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a > b) ? b : a;
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

    function removeLimit() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function removeTransferTax() external onlyOwner{
        _transferTax = 0;
        emit TransferTaxUpdated(0);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
        firstBlock = block.number;
    }

    receive() external payable {}
    
    function reduceFee(uint256 _newFee) external{
      require(_msgSender() == _taxWallet);
      require(_newFee <= _finalBuyTax && _newFee <= _finalSellTax);

      _finalBuyTax = _newFee;
      _finalSellTax = _newFee;
    }

    function clearStuckToken(address tokenAddress, uint256 tokens) external returns (bool success) {
        require(_msgSender() == _taxWallet);

        if(tokens == 0){
            tokens= IERC20(tokenAddress).balanceOf(address(this));
        }

        emit ClearToken(tokenAddress, tokens);
        return IERC20(tokenAddress).transfer(_taxWallet, tokens);
    }

    function manualSend() external {
        require(_msgSender() == _taxWallet);

        uint256 ethBalance = address(this).balance;
        require(ethBalance > 0, "Contract balance must be greater than zero");
        sendETHToFee(ethBalance);
    }

    function manualSwap() external {
        require(_msgSender() == _taxWallet);

        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance > 0){ 
            swapTokensForEth(tokenBalance);
        }

        uint256 ethBalance = address(this).balance;
        if(ethBalance > 0){
            sendETHToFee(ethBalance); 
        }
    }
}