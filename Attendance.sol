// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Owned {
    address owner;
    string password;
    
    constructor() {
        owner = msg.sender;
        password = "";
    }
    
   modifier onlyAdmin {
       require(msg.sender == owner, "This is an Admin function");
       _;
   }
}


contract AttendanceSheet is Owned {
    
    struct Student {
        string srn;
        string name;
        string dept;
        uint gradYear;

        string[] subjects;

        mapping(string => uint) attendence;
    }
    
    struct Teacher {
        string tid;
        string name;
        string[] subjects;
        string dept;
    }

    struct Info{
        string srn;
        uint attendance;
    }


    mapping(address => string) private s_addressMap;
    mapping (string => Student) public studentList;
    mapping (string => bool) private studentExists; 
    string[] public srnList;
    address[] private s_adds;

    string[] public subjects;
    
    mapping (address => string) private t_addressMap;
    mapping (string => Teacher) public teacherList;
    mapping (string => bool) private teacherExists;
    string[] public teacherIdList;
    address[] private t_adds;



    event studentCreationEvent(
        
        string name,
        string srn,
        string dept,
        uint gradYear
    );
    
    event teacherCreationEvent(
        string tid,
       string name,
       string dept
    ); 



    modifier onlyStudent{
        bool found = false;
        for (uint i = 0; i < s_adds.length; i++) {
            if (s_adds[i] == msg.sender) {
                found = true;
                break;
            }
        }
        require(found, "You are not registered as a student");
        _;
    }
    modifier onlyTeacher{
        bool found = false;
        for (uint i = 0; i < t_adds.length; i++) {
            if (t_adds[i] == msg.sender) {
                found = true;
                break;
            }
        }
        require(found, "You are not registered as a teacher");
        _;
    }

    //Student Functions:


    function regAsStudent(string memory _srn,  string memory _name, string memory _dept,  uint _gradYear) public returns(bool,string memory){

            bool found = false;
            for(uint i =0; i< s_adds.length;i++){
                if(s_adds[i] == msg.sender){
                    found = true;
                }
            }

            require(!found, "Repetion. You have already registered");
            require(!studentExists[_srn], "Repetion. Student with this srn exists.");

            if(!studentExists[_srn]){
                Student storage student = studentList[_srn];
                student.srn = _srn;
                student.name = _name;
                student.dept = _dept;
                student.gradYear = _gradYear;

                srnList.push(_srn);
                studentExists[_srn] = true; // Mark student as exists
                emit studentCreationEvent(  _name, _srn, _dept, _gradYear);

                s_adds.push(msg.sender);
                s_addressMap[msg.sender] = _srn;

                return(true,"Student added successfully");
            }else{
                return (false,"already exists");
            }
    }   

    function a_addSub(string memory _sub) onlyAdmin public  returns (bool, string memory){
        bool found = false;
        for(uint i =0; i< subjects.length; i++){
            if(keccak256(bytes(subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        }

        require(!found, "Repetition. Subject already exists");

        subjects.push(_sub);
        return (true, "Success. Added new subject");
    }

    function s_enrollToSub( string memory _sub) onlyStudent public returns(bool,string memory) {

        bool found = false;
        for(uint i =0; i< subjects.length; i++){
            if(keccak256(bytes(subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        }

        require(found, "Error. Subject does not exist");

        string storage srn = s_addressMap[msg.sender];

        found = false;
        for(uint i =0; i< studentList[srn].subjects.length; i++){
            if(keccak256(bytes(studentList[srn].subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        }

        require(!found, "Repetition. You are already enrolled in this subject.");

        studentList[srn].subjects.push(_sub);
        studentList[srn].attendence[_sub] = 0;
        return (true, "Success. Enrolled to subject");
        
    }

    function s_addAttendance( string memory _sub) onlyStudent public returns (bool, string memory){
        
        bool found = false;
        for(uint i =0; i< subjects.length; i++){
            if(keccak256(bytes(subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        }

        require (found, "Error. Subject does not exist");

        found = false;

        string storage srn = s_addressMap[msg.sender];

        for(uint i =0; i<studentList[srn].subjects.length ; i++){
            if(keccak256(bytes(studentList[srn].subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        } 

        require (found,"Error. Student not enrolled for this course");

        studentList[srn].attendence[_sub] = studentList[srn].attendence[_sub] + 1;

        return (true,"Success. Attendance incremented.");
    }

    function s_showAttendence(string memory _sub) onlyStudent public view returns (uint){

        bool found = false;
        for(uint i =0; i< subjects.length; i++){
            if(keccak256(bytes(subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        }

        require(found,"Not enrolled to this subject");

        string storage srn = s_addressMap[msg.sender];

        found = false;

        for(uint i =0; i<studentList[srn].subjects.length ; i++){
            if(keccak256(bytes(studentList[srn].subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        } 

        require(found,"Not enrolled in this subject");

        return studentList[srn].attendence[_sub];
    }

    // Teacher Functions:

    function regAsTeacher(string memory _tid, string memory _name, string memory _dept)  public returns(bool,string memory){
    
        bool found = false;
        for(uint i =0; i< t_adds.length;i++){
            if(t_adds[i] == msg.sender){
                found = true;
            }
        }
        for(uint i =0; i< s_adds.length;i++){
            if(s_adds[i] == msg.sender){
                found = true;
            }
        }
        require(!found, "Repetition. You have already registered.");

        require(!teacherExists[_tid], "Repetition. Teacher with this tid already exists.");

        if(!teacherExists[_tid]){
            Teacher storage teacher = teacherList[_tid];
            teacher.tid = _tid;
            teacher.name = _name;
            teacher.dept = _dept;

            teacherIdList.push(_tid);
            teacherExists[_tid] = true; // Mark teacher as exists

            emit teacherCreationEvent(_tid, _name, _dept);

            t_adds.push(msg.sender);
            t_addressMap[msg.sender] = _tid;

            return(true,"signup");
        }else{
                return(false,"already exists");
        }
    }

    function t_teachSub(string memory _sub) onlyTeacher public returns(bool, string memory){
        bool found = false;
        for(uint i =0; i< subjects.length; i++){
            if(keccak256(bytes(subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        }
        require(found, "Error. Subject does not exist");

        string memory tid = t_addressMap[msg.sender];
        found = false;
        for(uint i=0; i< teacherList[tid].subjects.length; i++){
            if(keccak256(bytes(teacherList[tid].subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        }

        require(!found,"Repetion. You already teach this subject.");

        teacherList[tid].subjects.push(_sub);

        return (true,"Success. Added teacher to subject.");
    }

    function t_getAttendance(string memory _srn, string memory _sub) onlyTeacher public view returns (uint) {

        require(studentExists[_srn], "Error. Invalid srn");

        string memory tid = t_addressMap[msg.sender];

        bool found = false;

        for(uint i =0; i< teacherList[tid].subjects.length; i++){
            if( keccak256(bytes(teacherList[tid].subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        }
        require(found, "Error. You do not teach this subject.");

        found = false;

        for(uint i =0; i< studentList[_srn].subjects.length; i++){
            if( keccak256(bytes(studentList[_srn].subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        }
        require(found, "Error. Student has not enrolled for this subject.");

        return studentList[_srn].attendence[_sub];

    }

    function t_changeAttendance(string memory _srn, string memory _sub, uint value) onlyTeacher public returns (bool, string memory) {

        require(studentExists[_srn], "Error. Invalid srn");

        string memory tid = t_addressMap[msg.sender];

        bool found = false;

        for(uint i =0; i< teacherList[tid].subjects.length; i++){
            if( keccak256(bytes(teacherList[tid].subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        }
        require(found, "Error. You do not teach this subject.");

        found = false;

        for(uint i =0; i< studentList[_srn].subjects.length; i++){
            if( keccak256(bytes(studentList[_srn].subjects[i])) == keccak256(bytes(_sub))){
                found = true;
            }
        }
        require(found, "Error. Student has not enrolled for this subject.");

        studentList[_srn].attendence[_sub] = value;
        return (true, "Success. Attendance value changed successfully.");

    }
  

}