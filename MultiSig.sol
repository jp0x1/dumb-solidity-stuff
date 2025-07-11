// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSig {
    address[] public owners;
    uint256 public required;
    uint256 public userid = 0;
    uint256 public count = 0;
    
//   A address for the destination of the transaction's value.
// A uint256 value of the transaction in wei.
// A bool named executed* which indicates if the transaction has been executed.  
    struct Transaction {
        address destination;
        uint256 transactionValue;
        bool executed;
        bytes data;
    }

    mapping (uint256 => Transaction) public transactions;
    mapping (uint256 => mapping(address => bool)) public confirmations;
    mapping (uint256 => uint256) public confirmationCount;
    constructor (address[] memory _owners, uint256 _confirmations) {
        if (_owners.length == 0 || _confirmations == 0 || _confirmations > _owners.length) {
            revert();
        }
        owners = _owners;
        required = _confirmations;
    }
    // return total number of transactions stored.
    function transactionCount() external view returns (uint256){
        return count;
    }

    function addTransaction(address _destination, uint256 value, bytes memory data) internal returns (uint256){
        transactions[userid] = (Transaction(_destination, value, false, data));
        uint256 currentUserID = userid;
        userid++;
        count++;
        return currentUserID;
    }

    function confirmTransaction (uint256 _transactionId) public {
        bool isOwner = false;
        for (uint256 i=0; i < owners.length; i++) {
            if (msg.sender == owners[i]) {
                isOwner = true;
            }
        }
        if (!isOwner){
            revert();
        }
        confirmations[_transactionId][msg.sender] = true;
        confirmationCount[_transactionId] += 1;
        
        if (isConfirmed(_transactionId)) {
            executeTransaction(_transactionId);
        }
    }

    function getConfirmationsCount(uint256 _transactionId) public view returns (uint256) {
        return confirmationCount[_transactionId];
    }

    function submitTransaction(address destination, uint256 value, bytes memory data) external {
        uint256 currentuserid = addTransaction(destination, value, data);
        confirmTransaction(currentuserid);
    }
    
    function isConfirmed(uint _transactionId) public view returns (bool) {
        if (confirmationCount[_transactionId] >= required) {
            return true;
        }
        return false;
    }

    function executeTransaction(uint  _transactionId) public {
        if (!isConfirmed(_transactionId)) {
            revert();
        }
        if (transactions[_transactionId].executed) {
            revert("Already executed");
        }
        address destinationAddr = transactions[_transactionId].destination;
        uint256 value = transactions[_transactionId].transactionValue;
        (bool success, ) = destinationAddr.call{ value: value}(transactions[_transactionId].data);
        require(success, "Failed to execute transaction");
        transactions[_transactionId].executed = true;
    }

    receive() external payable {
        
    }

}
