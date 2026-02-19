// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract School_Management {
    //owner of the contract
    address public owner;

    //constructor set as owner
    constructor() {
        owner = msg.sender; 
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

    //add +1 to stdent and staff created  i.e  update the numbers of student band staff created
    uint256 public studentIdCount = 0;
    uint256 public staffIdCount = 0;

    // this throw success message for an event
    event StudentFeePaid(address student, uint256 amount);
    event StaffPaid(address staff, uint256 amount, uint256 timestamp);
    event StudentCreated(uint256 id, string studentName, address studentAddress, uint256 timestamp);
    event StaffCreated(uint256 id, string staffName, address staffAddress);


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
        block.timestamp,
        _studentAddress,
        true,
        true
    );
    studentLists.push(students[_studentAddress]);

    emit StudentCreated(studentIdCount, _studentName, _studentAddress, block.timestamp);
    emit StudentFeePaid(_studentAddress, msg.value);
     
    } 

    //get the total students
    function getTotalStudents() public view returns (uint256) {
        return studentLists.length;
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
        0
        _staffAddress,
        true,
        true
    );
    staffLists.push(staffs[_staffAddress]);
    emit StaffCreated(staffIdCount, _staffName, _staffAddress);
    } 

     //get the total staffs
    function getTotalStaff() public view returns (uint256) {
        return staffLists.length;
    }

    //pay staffs salary  
    function payStaffSalary(address _staff) public {
        require(msg.sender == owner, "Only Admin canpay Staffs");

        for (uint i = 0; i < staffLists.length; i++) {

            if (staffLists[i].staffAddress == _staff) {
                // payable(_staff).transfer(staffs[i].salary);

                /* used call value becusec solidity transfer() and send() are now considered unsafe for sending 
                Ether due to gas limitations*/
                (bool sent, ) = _staff.call{value: staffLists[i].salary}("");
                require(sent, "Failed to send Ether");

                emit StaffPaid(_staff, staffLists[i].salary, block.timestamp);
            }
        }
    }

    // check contract balance
    function getContractBalance() external view returns (uint256){
        return address(this).balance;
    }

}