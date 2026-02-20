// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// contract Erc20 {

//     string public name;
//     string public symbol;
//     uint8 public decimals;
//     uint256 public totalSupply;

//     // store balances to a specific addres
//     mapping(address => uint256) public balances;

//     // store allowances (owner-spender-allowance) 
//     mapping(address => mapping(address => uint256)) public allowances;

//     // this throw success message for an event
//     event Transfer(address from, address to, uint256 value);
//     event Approval(address owner, address spender, uint256 value);

//     // create a constructor 
//         constructor(
//         string memory _name,
//         string memory _symbol,
//         uint8 _decimals,
//         uint256 _initialSupply){
//             name = _name;
//             symbol = _symbol;
//             decimals = _decimals;
//             totalSupply = _initialSupply;
//             balances[msg.sender] = _initialSupply;

//             emit Transfer(address(0), msg.sender, _initialSupply);
//         }

//     // checks the balance
//     function balanceOf(address account) public view returns (uint256) {
//         return balances[account];
//     }

//     // transfer to the address 
//     function transfer(address to, uint256 amount) public returns (bool) {
//         require(balances[msg.sender] >= amount, "Not enough tokens");
//         balances[msg.sender] -= amount;
//         balances[to] += amount;

//         emit Transfer(msg.sender, to, amount);
//         return true;
//     }

//     // approve the spender to spend fixed amount stated by the owner
//     function approve(address spender, uint256 amount) public returns (bool) {
//         allowances[msg.sender][spender] = amount;

//         emit Approval(msg.sender, spender, amount);
//         return true;
//     }

//     // check allowance balance
//     function allowance(address owner, address spender) public view returns (uint256) {
//         return allowances[owner][spender];
//     }

   
// }

// INTERFACE
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
   
}

contract ERC20 is IERC20 {
    string constant NAME = "NITRO";
    string constant SYMBOL = "NTR";
    uint8 constant DECIMAL = 18;
    // uint256 constant total_supply = 2_000_000_000_000_000_000_000;
    uint256 total_supply;
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    //function for name
    function name() public view returns (string memory){
        return NAME;
    }

    //function for symbol
    function symbol() public view returns (string memory){
        return SYMBOL;
    }

    //function to set decimal
    function decimals() external view returns (uint8) {
        return DECIMAL;
    }

    //function for total supply of tokens
    function totalSupply() external view returns (uint256) {
        return total_supply;
    }

    //get balance of owner
    function balanceOf(address _owner) external view returns (uint256 balance){
        return balances[_owner];
    }

    // transfer 
    function transfer(address _to, uint256 _value) external returns (bool success){
        require(_to != address(0), "Cant transfer to Zero Address");
        require(_value >= 0, "Can't send zero value");
        require(balances[msg.sender] >= _value, "Insufficient Fundss");

        //deduct the balances[msg.sender] balance 
        balances[msg.sender] = balances[msg.sender] - _value;

        //
        balances[_to] = balances[_to] + _value;

        //event message
        emit Transfer(msg.sender, _to, _value);

        return true;
    }
    
    //function that returns how much a spender is allowed to spend on behalf of the owner.
    function allowance(address _owner, address _spender) external view returns (uint256 remaining){
       return allowances[_owner][_spender];
    }


    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success){
        require(_to != address(0), "Cant transfer to Zero Address");
        require(balances[_from] >= _value, "allowance is greater than your balance, Insufficient funds");
        require(_value >= 0, "Can't send zero value");
        require(allowances[_from][msg.sender] >= _value, "Insufficient allowance");

         // Reduce the allowance 
        allowances[_from][msg.sender] = allowances[_from][msg.sender] - _value;

        //add to the _to balance
        balances[_to] = balances[_to] + _value;

        //deduct from _from
        balances[_from] = balances[_from] - _value;

        //event message
        emit Transfer(_from, _to, _value);

        return true;
    }


    function approve(address _spender, uint256 _value) external returns (bool success){
        require(_spender != address(0), "Cant transfer to Zero Address");
        require(_value >= 0, "Can't send zero value");
        require(balances[msg.sender] >= 0, 'Insufficient Allowance');

       allowances[msg.sender][_spender] = _value;
       emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function mint(address _owner, uint256 _amount) external {
        require(_owner != address(0), "Can't transfer to address zero");
        require(msg.sender == _owner, "Only owner can mint");

        // increase total supply
        total_supply = total_supply + _amount;
        //add tokens to the 'to' address
        balances[_owner] = balances[_owner] + _amount;

        
   
    }



}