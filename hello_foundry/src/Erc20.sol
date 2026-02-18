// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Erc20 {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // store balances to a specific addres
    mapping(address => uint256) public balances;

    // store allowances (owner-spender-allowance) 
    mapping(address => mapping(address => uint256)) public allowances;

    // this throw success message for an event
    event Transfer(address from, address to, uint256 value);
    event Approval(address owner, address spender, uint256 value);

    // create a constructor 
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

    // checks the balance
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    // transfer to the address 
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Not enough tokens");
        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // approve the spender to spend fixed amount stated by the owner
    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // check allowance balance
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

   
}
