# Blockchian-Based-Student-Attendence-Tracker

Attendance tracking is often a tedious task and lacks transparency. To make a simpler and authentic form of attendence marking, we have implemented the process through this smart contract.

### How it works:
The admin (deployer of contract) decides the subjects to be considered.
Each user needs to register themselves as a student or teacher first.
Students can enroll to any number of subjects (that are created by the admin)
Teachers can opt to teach any number of subjects (that are created by the admin)
Students can add their attendance (an increase by one) , marking themselves present. (since this action is done from their account, it sufficies as a form of authenticity.
The idea is that this function can be invoked perhaps by a smart card that the student swipes at the front of the classroom to mark their attendance.
Teachers can forcefully change the attendance of any student they teach. ( this is put in place as a backup measure)

### How to run this project:
1. Copy the smart contract code and deploy it on any blockchain IDE such as Remix.
2. Deploy the contract ( the address you deployed the contract will be the admin. You can call the create subject function from this address. )
3. Change the address and use the register functions to register as student or teacher
4. Repeat step 3 to create as many students or teachers needed.
5. Invoke add attendance function from a student account to add attendance.
