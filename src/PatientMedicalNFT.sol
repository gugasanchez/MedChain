// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PatientMedicalNFT is ERC1155, Ownable {
    mapping(uint256 => address) public nftCreators;
    mapping(uint256 => bool) public nftBurned;
    uint256 public currentTokenId = 1;

    constructor() ERC1155("https://ipfs.io/ipfs/bafybeicfktlte2rloeuolpwfwjqow2hwe44obljtrhq36tg3r6vulgizn4/ethereumSP.json") {}

    function _createNFT(address _to) external onlyOwner returns (uint256) {
        uint256 tokenId = currentTokenId++;
        nftCreators[tokenId] = msg.sender;
        _mint(_to, tokenId, 1, "");
        return tokenId;
    }

    function burnNFT(address _doctor) public returns (bool) {
        _burn(_doctor, (currentTokenId - 1), 1);

        return true;
    }

}
