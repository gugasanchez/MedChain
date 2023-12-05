// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PatientMedicalNFT.sol";
import "./AnamnesisContract.sol";

interface IPatientMedicalNFT {
    function _createNFT(address) external returns (uint256);
    function currentTokenId() external returns (uint256);
    function balanceOf(address, uint256) external returns (uint256);
    function burnNFT(address) external returns (bool);
}

contract HealthDashboard {

    AnamnesisContract public anamnesisContract;

    constructor() {
        anamnesisContract = new AnamnesisContract();
    }

    struct Diagnosis {
        string diagnosisName;
        string diagnosisId;
    }

    struct MedicalConsultationData {
        uint timestamp;
        string conditions;
        string medications;
        string observations;
        Diagnosis diagnosis;
    }

    mapping(address => MedicalConsultationData[]) private userMedicalRecords;
    mapping(address => address) public patientNFTContract;

    /* Função para usuário se registrar:
    - Deploy do contrato de NFTs do usuário
    - Deve relacionar o endereço do contrato ao endereço do usuário */

    function register() public returns (address){
        PatientMedicalNFT newPatientNFTContract = new PatientMedicalNFT();
        patientNFTContract[msg.sender] = address(newPatientNFTContract);

        return address(newPatientNFTContract);
    }

    /*Função para criar consulta:
    - Mint NFT
    */

    function startConsultation(address doctor) public returns (bool) {
        IPatientMedicalNFT(patientNFTContract[msg.sender])._createNFT(doctor);
        return true;
    }

    /* Função para verificar dados do paciente
    - Deve retornar todos os dados
    - Modifier: somente quem tem o NFT do paciente pode chamar essa função
     */

    modifier hasAccessToUserMedicalRecords(address patient) {

        uint256 _currentTokenId = IPatientMedicalNFT(patientNFTContract[patient]).currentTokenId();

        require(
            msg.sender == patient || IPatientMedicalNFT(patientNFTContract[patient]).balanceOf(msg.sender, (_currentTokenId - 1)) == 1,
            "Access denied. You must have the required NFT."
        );
        _;
    }

    function getUserMedicalRecords(address patient) public hasAccessToUserMedicalRecords(patient) returns (MedicalConsultationData[] memory) {
    
        return userMedicalRecords[patient];
    }

    /*Função para finalizar consulta:
    - Enviar os dados da consulta;
    - Burn do NFT
    - Remoção do valor 1 para o NFT */

    function finishConsultation(address patient, string memory _conditions, string memory _medications, string memory _observations, string memory _diagnosisName, string memory _diagnosisId) public hasAccessToUserMedicalRecords(patient) returns (bool) {
        
         address doctorWallet = msg.sender;

        Diagnosis memory _diagnosis = Diagnosis({
            diagnosisName: _diagnosisName,
            diagnosisId: _diagnosisId
        });

        MedicalConsultationData memory newConsultation = MedicalConsultationData(block.timestamp ,_conditions, _medications, _observations, _diagnosis);
        userMedicalRecords[patient].push(newConsultation);

        IPatientMedicalNFT(patientNFTContract[patient]).burnNFT(doctorWallet);

        return true;
    }

    function setAnamnesis(address _patient, string memory _familyHistory, string memory _immunizationHistory, string memory _surgicalHistory, string memory _allergiesAndReactions) public hasAccessToUserMedicalRecords(_patient) {
        anamnesisContract._setAnamnesis(_patient, _familyHistory, _immunizationHistory, _surgicalHistory, _allergiesAndReactions);
    }

    function getAnamnesis(address _patient) public hasAccessToUserMedicalRecords(_patient) {
        anamnesisContract._getAnamnesis(_patient);
    }
}