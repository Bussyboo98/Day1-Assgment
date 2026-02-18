// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Erc20 {

    // Token details
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;

    // Balances
    mapping(address => uint256) private balances;

    // Allowances
    mapping(address => mapping(address => uint256)) private allowances;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Constructor
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        _mint(msg.sender, initialSupply);
    }

    // Total supply
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // Balance
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    // Transfer
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    // Approve
    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Allowance
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    // Transfer from
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 currentAllowance = allowances[from][msg.sender];
        require(currentAllowance >= amount, "Allowance exceeded");

        allowances[from][msg.sender] = currentAllowance - amount;

        _transfer(from, to, amount);
        return true;
    }

    // Internal transfer
    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Invalid address");
        require(balances[from] >= amount, "Insufficient balance");

        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    // Internal mint
    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Invalid address");

        _totalSupply += amount;
        balances[to] += amount;

        emit Transfer(address(0), to, amount);
    }
}
