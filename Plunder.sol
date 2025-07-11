// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol";

contract Chest {
    function plunder(address[] memory addresses) external {
        for (uint256 i=0; i < addresses.length; i++) {
            // get the ERC20 tokens from each address
            IERC20 token = IERC20(addresses[i]);
            // get their balance
            uint256 balance = token.balanceOf(address(this));
            //transfer it to the sender aka person who created this contract
            token.transfer(msg.sender, balance);
        }
    }
}
