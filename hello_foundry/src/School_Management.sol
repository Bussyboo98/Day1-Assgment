// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {IERC20} from "./IERC20.sol";

contract School_Management {
    //owner of the contract
    address public owner;
    address token_address;



    //constructor set as owner
    constructor(address _token_address) {
        owner = msg.sender; 
        token_address = _token_address;
    }
    
    //student struct
    struct Student {
        uint256 studentId;
        string studentName;
        uint studentAge;
        string studentDepartment;
        string studentLevel;
        address studentAddress;
        uint256 paymentTimestamp;
        bool isCreated;
        bool isActive;
    }

    //staff struct
    struct Staff {
        uint staffId;
        string staffName;
        string staffRole;
        uint salary;
        address staffAddress;
        uint256 paymentTimestamp;
        bool isCreated;
        bool isActive;
        bool isSuspended;
    }

    
    //arrays store all registered students and staff
    Student[] public studentLists;

    Staff[] public staffLists;
    
    
    //store the stdents
    mapping(address => Student) public students;
   // store the staffs
    mapping(address => Staff) public staffs;


    // store studentfees and staff balance
    mapping(address => uint256) public studentFees;
    mapping(address => uint256) public staffBalance;

    mapping(address => uint256) erc20Savingsbalance;


    //add +1 to stdent and staff created  i.e  update the numbers of student band staff created
    uint256 public studentIdCount = 0;
    uint256 public staffIdCount = 0;

    // this throw success message for an event
    event StudentFeePaid(address student, uint256 amount);
    event StaffPaid(address staff, uint256 amount, uint256 timestamp);
    event StudentCreated(uint256 id, string studentName, address studentAddress, uint256 timestamp);
    event StaffCreated(uint256 id, string staffName, address staffAddress);
    event StudentRemoved(address studentAddress, uint256 timestamp);
    


    //level function - each level pays 1 ETH as it increases
    function getLevelStudent(string memory _studentLevel) public pure returns (uint256) {
        if (keccak256(bytes(_studentLevel)) == keccak256(bytes("100"))) return 1 ether;
        if (keccak256(bytes(_studentLevel)) == keccak256(bytes("200"))) return 2 ether;
        if (keccak256(bytes(_studentLevel)) == keccak256(bytes("300"))) return 3 ether;
        if (keccak256(bytes(_studentLevel)) == keccak256(bytes("400"))) return 4 ether;
        
        //error handling - if student eneters wrong level
        revert("Invalid  level");
    }


    // register student function
    // since student are paying during registration we use payable
    function registerStudent(string memory _studentName, uint256 _studentAge, string memory _studentDepartment,
     string memory _studentLevel, address _studentAddress) public payable{
    
        uint256 studentRequiredFee = getLevelStudent(_studentLevel);   
        require(msg.value == studentRequiredFee, "Incorrect school fees");

        
        studentIdCount++;
        students[_studentAddress] = Student(
        studentIdCount,
        _studentName,
        _studentAge,
        _studentDepartment,
        _studentLevel,
        _studentAddress,
        block.timestamp,
        true,
        true
    );
    studentLists.push(students[_studentAddress]);

    emit StudentCreated(studentIdCount, _studentName, _studentAddress, block.timestamp);
    emit StudentFeePaid(_studentAddress, msg.value);
     
    } 


    //student register and pay token
    function registerStudentPayERC20(string memory _studentName, uint256 _studentAge, string memory _studentDepartment,
     string memory _studentLevel, address _studentAddress, uint256 _amount) public {
        
        IERC20 token = IERC20(token_address);
        
        uint256 studentRequiredFee = getLevelStudent(_studentLevel);   
        require(_amount == studentRequiredFee, "Incorrect school token fees");

        require(token.balanceOf(_studentAddress) >= _amount, "Insufficient token balance");
        require(token.allowance(_studentAddress, address(this)) >= _amount, "Contract not approved for tokens");

        // transfer tokens from student to contract
        bool success = token.transferFrom(_studentAddress, address(this), _amount);
        require(success, "Token transfer failed");

        
        studentIdCount++;
        students[_studentAddress] = Student(
        studentIdCount,
        _studentName,
        _studentAge,
        _studentDepartment,
        _studentLevel,
        _studentAddress,
        block.timestamp,
        true,
        true
    );
    studentLists.push(students[_studentAddress]);

    emit StudentCreated(studentIdCount, _studentName, _studentAddress, block.timestamp);
    emit StudentFeePaid(_studentAddress, _amount);
     
    } 

    //get the total students
    function getTotalStudents() public view returns (uint256) {
        return studentLists.length;
    }


    function removeStudent(address _studentAddress) public {

        require(msg.sender == owner, "Only Admin can remove students");

        require(students[_studentAddress].studentAddress != address(0), "Student Address not found");

        //delete student from map
        delete students[_studentAddress];

        // remove student from list
        for (uint8 i; i < studentLists.length; i++) {
            if (studentLists[i].studentAddress == _studentAddress) {
                studentLists[i] = studentLists[studentLists.length - 1];
                studentLists.pop();
            }
     
        } 
        emit StudentRemoved(_studentAddress, block.timestamp);

    }
    //register staff
    function registerStaff(string memory _staffName, string memory _staffRole, uint _salary, address _staffAddress) public {

        require(msg.sender == owner, "Only Admin can register staff");
        
        staffIdCount++;
            staffs[_staffAddress] = Staff(
            staffIdCount,
            _staffName,
            _staffRole,
            _salary,
            _staffAddress,
            0,
            true,
            true, 
            false
        );
        staffLists.push(staffs[_staffAddress]);
        emit StaffCreated(staffIdCount, _staffName, _staffAddress);
    } 

     //get the total staffs
    function getTotalStaff() public view returns (uint256) {
        return staffLists.length;
    }



    function suspendStaff(address _staffAddress) public{
        require(msg.sender == owner, "Only Admin can suspend staff");

        require(staffs[_staffAddress].staffAddress != address(0), "Staff with this address does not exist");

        staffs[_staffAddress].isSuspended = true;
    }


     //register staff
    function employStaff(string memory _staffName, string memory _staffRole, uint _salary, address _staffAddress) public {

        require(msg.sender == owner, "Only Admin can register staff");

        require(!staffs[_staffAddress].isCreated, "Staff exist already");
        
        staffIdCount++;
            staffs[_staffAddress] = Staff(
            staffIdCount,
            _staffName,
            _staffRole,
            _salary,
            _staffAddress,
            0,
            true,
            true, 
            false
        );
        staffLists.push(staffs[_staffAddress]);
        emit StaffCreated(staffIdCount, _staffName, _staffAddress);
    } 



    //pay staffs salary  
    function payStaffSalary(address _staff) public {
        require(msg.sender == owner, "Only Admin canpay Staffs");

        for (uint i = 0; i < staffLists.length; i++) {

            if (staffLists[i].staffAddress == _staff) {
                (bool success, ) = _staff.call{value: staffLists[i].salary}("");
                require(success, "Transfer failed");


                emit StaffPaid(_staff, staffLists[i].salary, block.timestamp);
            }
        }
    }

    //pay staff token
    function payStasffERC20(address _staff, uint256 _amount) external {
        require(_amount > 0, "Can't send zero value");
        require(msg.sender == owner, "Only Admin canpay Staffs");
    

        // check contract balance
        IERC20 token = IERC20(token_address);
        require(token.balanceOf(address(this)) >= _amount, "Insufficient Token");

        // transfer tokens to staff
        bool success = token.transfer(_staff, _amount);
        require(success, "Transfer failed");

        emit StaffPaid(_staff, _amount, block.timestamp);
        
    }

    // check contract balance
    function getContractBalance() external view returns (uint256){
        return address(this).balance;
    }

}