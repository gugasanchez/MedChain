// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract AnamnesisContract {
    
    struct Anamnesis {
        string familyHistory;
        string immunizationHistory;
        string surgicalHistory;
        string allergiesAndReactions;
    }

    mapping(address => Anamnesis) public userAnamnesis;

    function _setAnamnesis (address patient, string memory _familyHistory, string memory _immunizationHistory, string memory _surgicalHistory, string memory _allergiesAndReactions) public returns (bool){
        userAnamnesis[patient] = Anamnesis(_familyHistory, _immunizationHistory, _surgicalHistory, _allergiesAndReactions);

        return true;
    }

    function _getAnamnesis (address patient) public view returns (Anamnesis memory) {
        return userAnamnesis[patient];
    }
}