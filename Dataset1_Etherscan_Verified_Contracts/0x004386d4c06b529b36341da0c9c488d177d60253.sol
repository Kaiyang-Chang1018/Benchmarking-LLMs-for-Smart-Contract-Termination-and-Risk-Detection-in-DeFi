pragma solidity ^0.8.7;
//SPDX-License-Identifier: UNLICENCED
/*
    
    Telegram:
    https://t.me/Skeletor_ERC
    Website: 
    https://skeletor.vip/
*/



interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


contract Skeletor is IERC20 {
    
    // trading control;
    bool public canTrade = false;
    uint256 public launchedAt;
    bool isMevAllowed = false;
    
    
    
    // tokenomics - uint256 BN but located here fro storage efficiency
    uint256 _totalSupply = 666 * 10**12 * (10 **_decimals); //666 tril
    uint256 public _maxTxAmount = _totalSupply / 50; // 2%
    uint256 public _maxHoldAmount = _totalSupply / 50; // 2%

    //Important addresses    
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public pair;
    address public owner;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public pairs;

    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isMaxHoldExempt;
    mapping (address => bool) internal authorizations;

     /**
     * Function modifier to require caller to be authorized
     */

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    
    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    IDEXRouter public router;


    string constant _name = "Skeletor";
    string constant _symbol = "$SKULL";
    uint8 constant _decimals = 18;

    bool public initialTaxesEnabled = true;

    constructor () {
        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //Mainnet Uniswap
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this)); // ETH pair
        pairs[pair] = true;
        _allowances[address(this)][address(router)] = _totalSupply;
        isMaxHoldExempt[pair] = true;
        isMaxHoldExempt[DEAD] = true;
        isMaxHoldExempt[ZERO] = true;
        
        owner = msg.sender;
        isTxLimitExempt[owner] = true;
        authorizations[owner] = true;
        isMaxHoldExempt[owner] = true;
        _balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);

    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender];} 
    

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }
    
    
    function allowtrading()external authorized {
        canTrade = true;
    }
    
    function addNewPair(address newPair)external authorized{
        pairs[newPair] = true;
        isMaxHoldExempt[newPair] = true;
    }
    
    function removePair(address pairToRemove)external authorized{
        pairs[pairToRemove] = false;
        isMaxHoldExempt[pairToRemove] = false;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(_totalSupply)){
            require(_allowances[sender][msg.sender] >= amount, "Insufficient allowance");
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        if(!canTrade){
            require(sender == owner, "CONTRACT, Only owner or presale Contract allowed to add LP"); // only owner allowed to trade or add liquidity
        }
        if(sender != owner && recipient != owner){
            if(!pairs[recipient] && !isMaxHoldExempt[recipient]){
                require (balanceOf(recipient) + amount <= _maxHoldAmount, "CONTRACT, cant hold more than max hold dude, sorry");
            }
        }
        if(!isMevAllowed){
            if(pairs[sender]){ // its a buy
                require(address(tx.origin) == address(recipient), "MEV BOTS ARE NOT ALLOWED TO TRADE");
            }
        }
        
        checkTxLimit(sender, recipient, amount);
        require(_balances[sender] >= amount);
        if(!launched() && pairs[recipient]){ require(_balances[sender] > 0); launch(); }
        
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, address reciever, uint256 amount) internal view {
        if(sender != owner && reciever != owner){
            require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        }
    }

    // returns any mis-sent tokens to the marketing wallet
    function claimtokensback(IERC20 tokenAddress) external authorized {
        payable(owner).transfer(address(this).balance);
        tokenAddress.transfer(owner, tokenAddress.balanceOf(address(this)));
    }

    function setIsMevAllowedToTrade(bool isAllowed) external authorized {
        isMevAllowed = isAllowed;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.timestamp;
    }


    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 200, "CONTRACT, must be higher than 0.5%");
        require(amount > _maxTxAmount, "CONTRACT, can only ever increase the tx limit");
        _maxTxAmount = amount;
    }


    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }
    /*
    Dev sets the individual buy fees
    */
   
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

    event AutoLiquify(uint256 amountPairToken, uint256 amountToken);

}