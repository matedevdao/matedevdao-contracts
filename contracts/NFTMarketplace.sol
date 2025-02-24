// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract NFTMarketplace is ReentrancyGuard, ERC721Holder {
    struct Listing {
        address owner;
        address tokenAddress;
        uint256 tokenId;
        uint256 price;
    }

    uint256 public nextListingId;
    mapping(uint256 => Listing) public listings;

    event Listed(
        uint256 indexed listId,
        address indexed owner,
        address indexed tokenAddress,
        uint256 tokenId,
        uint256 price
    );
    event Bought(uint256 indexed listId, address indexed buyer);
    event Cancelled(uint256 indexed listId);

    function list(address tokenAddress, uint256 tokenId, uint256 price) external nonReentrant {
        require(price > 0, "NFTMarketplace: price must be positive");

        uint256 listId = nextListingId++;
        Listing storage listing = listings[listId];

        listing.owner = msg.sender;
        listing.tokenAddress = tokenAddress;
        listing.tokenId = tokenId;
        listing.price = price;

        IERC721(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId);

        emit Listed(listId, msg.sender, tokenAddress, tokenId, price);
    }

    function buy(uint256 listId) external payable nonReentrant {
        Listing memory listing = listings[listId];
        require(listing.owner != address(0), "NFTMarketplace: listing must exist");
        require(msg.value == listing.price, "NFTMarketplace: must send exact price");

        IERC721(listing.tokenAddress).safeTransferFrom(address(this), msg.sender, listing.tokenId);

        payable(listing.owner).transfer(msg.value);

        delete listings[listId];

        emit Bought(listId, msg.sender);
    }

    function cancel(uint256 listId) external nonReentrant {
        Listing memory listing = listings[listId];
        require(listing.owner != address(0), "NFTMarketplace: listing must exist");
        require(listing.owner == msg.sender, "NFTMarketplace: cannot cancel another's listing");

        IERC721(listing.tokenAddress).safeTransferFrom(address(this), msg.sender, listing.tokenId);

        delete listings[listId];

        emit Cancelled(listId);
    }
}
