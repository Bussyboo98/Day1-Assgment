// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.3;


contract MultisigTransact {

    struct Transaction {
        address to;
        uint value;
        bool executed;
        bytes data;
        uint256 numConfirmations;
    }
    
   
    address[] public owners;
    uint public required;
    mapping(address => bool) public isOwner;
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    event Deposit(address sender, uint256 amount, uint256 balance);
    event SubmitTransaction(address owner, uint256 transactId, address to, uint256 value, bytes data);
    event ConfirmTransaction(address owner, uint256 transactId);
    event ExecuteTransaction(address owner, uint256 transactId);
    event RevokeConfirmation(address owner, uint256 transactId);


    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier notConfirmed(uint256 _transactId){
        require(!isConfirmed[_transactId][msg.sender], "transaction is already confirmed");
        _;
    }

    modifier notExecuted(uint256 _transactId){
        require(!transactions[_transactId].executed, "transaction is executed already");
        _;
    }

    modifier isExist(uint256 _transactId){
         require(_transactId < transactions.length, "transaction does not exist");
         _;
    }

    constructor(address[] memory _owners, uint _required){
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "invalid number of required confirmations");

        for(uint256 i = 0; i < _owners.length; i++){
            address owner = _owners[i];

            require(owner != address(0), "invalid owner, must not be a zero address");
           
            require(!isOwner[owner], "Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);

        }
        required = _required;

    }
   
    receive() external payable{
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(address _to, uint256 _transactId, uint256 _value, bytes memory _data) public onlyOwner(){
        require(_to != address(0), "Invalid address");
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        })
        );
        emit SubmitTransaction(msg.sender, _transactId, _to, _value, _data);
    }

    function confirmTransaction(uint256 _transactId) public onlyOwner isExist(_transactId)
    notConfirmed(_transactId)notExecuted(_transactId){
        Transaction storage transaction = transactions[_transactId];
        transaction.numConfirmations += 1;
        isConfirmed[_transactId][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _transactId);

    }

    function executeTransaction(uint256 _transactId) public onlyOwner isExist(_transactId) notExecuted(_transactId){
        Transaction storage transaction = transactions[_transactId];

        require(transaction.numConfirmations >= required, "Not enough confirmation");
        
        transaction.executed = true;
        
        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);

        require(success, "transaction failed");

        emit ExecuteTransaction(msg.sender, _transactId);

    }

    function cancelTransaction(uint256 _transactId) public onlyOwner notExecuted(_transactId){
        Transaction storage transaction = transactions[_transactId];
        transaction.executed = true;
    } 

    function revokeConfirmation(uint256 _transactId) public onlyOwner isExist(_transactId) notExecuted(_transactId){
        Transaction storage transaction = transactions[_transactId];
        require(isConfirmed[_transactId][msg.sender], "transaction not confirmed");
        transaction.numConfirmations -= 1;
    
        isConfirmed[_transactId][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _transactId);

    }

    function getTransaction(uint256 _transactId) public view returns(address to, uint256 value,
    bytes memory data, bool executed,uint256 numConfirmations ){
        Transaction storage transaction = transactions[_transactId];
        return(
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
        
    }


    function getAllTransaction() public view returns(Transaction[] memory){
        return transactions;
    }

    function getOwners() public view returns(address[] memory){
        return owners;
    }

    function getTransactionCount() public view returns(uint256){
        return transactions.length;
    }
}