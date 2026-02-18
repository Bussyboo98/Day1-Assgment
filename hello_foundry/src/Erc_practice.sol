// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Erc_practice {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) private balances;

    event DepositSuccessful(address indexed sender, uint256 indexed amount);
    event Transfer(address from, address to, uint256 value);
    event WithdrawalSuccessful(address indexed receiver, uint256 indexed amount, bytes data);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply){
            name = _name;
            symbol = _symbol;
            decimals = _decimals;
            totalSupply = _initialSupply;
            balances[msg.sender] = _initialSupply;

            emit Transfer(address(0), msg.sender, _initialSupply);
        }

    function balanceOf(address user_account) public view returns (uint256 balance){
        return balances[user_account];
    }

    function deposit() external payable {
        require(msg.value > 0,  "Cant deposit zero value");
        balances[msg.sender] = balances[msg.sender] + msg.value;
        emit DepositSuccessful(msg.sender, msg.value);
    }

    function withdraw(uint _amount) external payable{
        require(msg.sender != address(0), "Address zero detected");
        uint256 userSavings_ = balances[msg.sender];
        require(userSavings_ > 0,  "Insufficient funds");
        balances[msg.sender] = userSavings_ - _amount;
        (bool result, bytes memory data) = payable(msg.sender).call{value: _amount}("");

        require(result, "tranfer failed");

        emit WithdrawalSuccessful(msg.sender, _amount, data);
    }

   
}
