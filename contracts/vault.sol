// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
    address public owner;
    
    struct Beneficiary {
        uint256 amount;
        uint256 timeLock;
        bool claimed; 
    }
    
    mapping(address => Beneficiary) public beneficiaries;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner Have access to this");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function createBeneficiary(address _beneficiary, uint256 _amount, uint256 _timeLock) public onlyOwner {
        require(beneficiaries[_beneficiary].amount == 0, "Beneficiary already exists");
        require(address(this).balance >= _amount, "Insufficient balance");
        beneficiaries[_beneficiary] = Beneficiary(_amount, block.timestamp + _timeLock, false);
        payable(_beneficiary).transfer(_amount);
    }
    

    function removeBeneficiary(address _beneficiary) public onlyOwner {
        require(beneficiaries[_beneficiary].amount > 0 && !beneficiaries[_beneficiary].claimed, "Beneficiary does not exist or has claimed their funds");
        payable(address(this)).transfer(beneficiaries[_beneficiary].amount);
        delete beneficiaries[_beneficiary];
    }
    
 
    function claimFunds() public {
        require(beneficiaries[msg.sender].amount > 0 && !beneficiaries[msg.sender].claimed && block.timestamp >= beneficiaries[msg.sender].timeLock, "You are not eligible to claim your funds");
        beneficiaries[msg.sender].claimed = true;
        payable(msg.sender).transfer(beneficiaries[msg.sender].amount);
    }
    
}
