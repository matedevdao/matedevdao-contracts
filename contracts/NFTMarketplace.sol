// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract NFTMarketplace is ReentrancyGuard, ERC721Holder {
    error InvalidPrice();
    error ListingDoesNotExist();
    error NotOwner();

    using Address for address payable;

    struct Listing {
        address owner;
        address nftAddress;
        uint256 tokenId;
        uint256 price;
    }

    uint256 public nextListingId;
    mapping(uint256 => Listing) public listings;

    event Listed(
        uint256 indexed listId,
        address indexed owner,
        address indexed nftAddress,
        uint256 tokenId,
        uint256 price
    );
    event Bought(uint256 indexed listId, address indexed buyer);
    event Cancelled(uint256 indexed listId);

    function list(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external nonReentrant {
        if (price <= 0) revert InvalidPrice();

        uint256 listId = nextListingId++;
        Listing storage listing = listings[listId];

        listing.owner = msg.sender;
        listing.nftAddress = nftAddress;
        listing.tokenId = tokenId;
        listing.price = price;

        IERC721(nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        emit Listed(listId, msg.sender, nftAddress, tokenId, price);
    }

    function buy(uint256 listId) external payable nonReentrant {
        Listing memory listing = listings[listId];
        if (listing.owner == address(0)) revert ListingDoesNotExist();
        if (msg.value != listing.price) revert InvalidPrice();

        IERC721(listing.nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            listing.tokenId
        );

        payable(listing.owner).sendValue(msg.value);

        delete listings[listId];

        emit Bought(listId, msg.sender);
    }

    function cancel(uint256 listId) external nonReentrant {
        Listing memory listing = listings[listId];
        if (listing.owner == address(0)) revert ListingDoesNotExist();
        if (listing.owner != msg.sender) revert NotOwner();

        IERC721(listing.nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            listing.tokenId
        );

        delete listings[listId];

        emit Cancelled(listId);
    }
}
