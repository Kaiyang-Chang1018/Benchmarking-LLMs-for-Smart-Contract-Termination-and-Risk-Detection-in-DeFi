// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function burn(uint256 amount) external returns (bool);
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


contract SwapRootxToSRootx is Context {
  using SafeMath for uint256;
  using Address for address;

  IERC20 public rootx;
  IERC20 public srootx;

  uint256 public ratio = 5; // 5 srootx / 1 rootx
  address public admin; 

  constructor(address _rootx, address _srootx) {
    admin = _msgSender();
    rootx = IERC20(_rootx);
    srootx = IERC20(_srootx);
  }

  function RootxPot() public view returns (uint) {
    return rootx.balanceOf(address(this));
  }

  function SRootxPot() public view returns (uint) {
    return srootx.balanceOf(address(this));
  }

  function CheckClaimable(uint amount) public view returns (uint) {
    require(srootx.balanceOf(msg.sender) >= amount, "Insufficient srootx balance");

    // Calculate equivalent rootx tokens based on the ratio
    uint256 rootxAmount = amount.div(ratio);
    return rootxAmount;
  }

  function swap(uint256 amount) public {
    require(srootx.balanceOf(msg.sender) >= amount, "Insufficient srootx balance");
    require(srootx.allowance(msg.sender, address(this)) >= amount, "Allowance too low");

    // Calculate equivalent rootx tokens based on the ratio
    uint256 rootxAmount = amount.div(ratio);

    // Transfer srootx from sender to this contract
    require(srootx.transferFrom(msg.sender, admin, amount), "srootx transfer failed");

    // Transfer equivalent rootx tokens to sender
    require(rootx.transfer(msg.sender, rootxAmount), "rootx transfer failed");
  }

  function withdrawRootx(uint256 amount) public onlyAdmin {    
    _withdrawRootx(amount);
  }
  function _withdrawRootx(uint256 amount) internal {
    require(rootx.transfer(admin, amount), "rootx transfer failed");
  }

  function withdrawSRootx(uint256 amount) public onlyAdmin {    
    _withdrawSRootx(amount);
  }
  function _withdrawSRootx(uint256 amount) internal {
    require(srootx.transfer(admin, amount), "srootx transfer failed");
  }

  function changeRootx(address _rootx) public onlyAdmin {
    rootx = IERC20(_rootx);
  }

  function changeSRootx(address _srootx) public onlyAdmin {
    srootx = IERC20(_srootx);
  }

  function changeRatio(uint _ratio) public onlyAdmin {
    ratio = _ratio;
  }

  function changeAdmin(address _admin) public onlyAdmin {
    admin = _admin;
  }

  modifier onlyAdmin() {
    require(admin == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
}