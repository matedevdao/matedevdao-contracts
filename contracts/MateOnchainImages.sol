// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface OnchainImageStorage {
    function image(uint256 tokenId) external view returns (string memory);
}

contract MateOnchainImages {
    OnchainImageStorage public onchainImageStorage;

    constructor(address _onchainImageStorage) {
        onchainImageStorage = OnchainImageStorage(_onchainImageStorage);
    }

    function getImages(uint256[] calldata tokenIds) external view returns (string[] memory) {
        string[] memory result = new string[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            result[i] = onchainImageStorage.image(tokenIds[i]);
        }
        return result;
    }
}
