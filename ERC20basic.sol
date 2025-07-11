// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Token {
    uint public totalSupply = 0;
    string public name = "MGCOIN";
    string public symbol = "uwu";
    uint8 public decimals = 18;

    event Transfer(address, address, uint256);
    mapping(address => uint256) balance;

    constructor () {
        totalSupply = 1000 * (10 ** 18);
        balance[address(msg.sender)] = totalSupply;
    }

    function balanceOf(address person) external view returns (uint256) {
        return balance[person];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        uint256 userAmt = this.balanceOf(msg.sender);
        if (userAmt < amount) {
            revert("not enough");
        }
        balance[recipient] += amount;
        balance[msg.sender] -= amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

}