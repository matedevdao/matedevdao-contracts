// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTHolderAggregator {
    function getHolders(
        address nftAddress,
        uint256 startTokenId,
        uint256 endTokenId
    ) external view returns (address[] memory) {
        address[] memory holders = new address[](endTokenId - startTokenId + 1);
        for (uint256 i = startTokenId; i <= endTokenId; i++) {
            try {
                holders[i - startTokenId] = IERC721(nftAddress).ownerOf(i);
            } catch { 
                holders[i - startTokenId] = address(0);
            }
        }
        return holders;
    }
}
