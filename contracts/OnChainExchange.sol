// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract OnChainExchange is ReentrancyGuard {
    enum AssetType {
        ERC20,
        ERC721,
        ERC1155
    }

    struct Asset {
        AssetType assetType;
        address tokenAddress;
        uint256 tokenId;
        uint256 amount;
    }

    struct TradeableAssetPackage {
        address owner;
        Asset[] assets;
        uint256 price;
        string description;
    }

    uint256 public nextListId;
    mapping(uint256 => TradeableAssetPackage) public listed;

    event Listed(uint256 listId, address owner, Asset[] assets, uint256 price, string description);
    event Bought(uint256 listId, address buyer);
    event Cancelled(uint256 listId);

    function list(Asset[] memory assets, uint256 price, string memory description) external {
        require(assets.length > 0, "OnChainExchange: assets must be non-empty");
        require(price > 0, "OnChainExchange: price must be positive");

        uint256 listId = nextListId++;
        TradeableAssetPackage storage listing = listed[listId];

        listing.owner = msg.sender;
        listing.price = price;
        listing.description = description;

        for (uint256 i = 0; i < assets.length; i++) {
            Asset memory asset = assets[i];

            require(asset.amount > 0, "OnChainExchange: asset amount must be positive");
            require(asset.tokenAddress != address(0), "OnChainExchange: asset token address must be non-zero");

            if (asset.assetType == AssetType.ERC20) {
                require(asset.tokenId == 0, "OnChainExchange: asset token id must be zero for ERC20");
                IERC20(asset.tokenAddress).transferFrom(msg.sender, address(this), asset.amount);
            } else if (asset.assetType == AssetType.ERC721) {
                require(asset.amount == 1, "OnChainExchange: asset amount must be 1 for ERC721");
                IERC721(asset.tokenAddress).safeTransferFrom(msg.sender, address(this), asset.tokenId);
            } else if (asset.assetType == AssetType.ERC1155) {
                IERC1155(asset.tokenAddress).safeTransferFrom(
                    msg.sender,
                    address(this),
                    asset.tokenId,
                    asset.amount,
                    ""
                );
            } else {
                revert("OnChainExchange: invalid asset type");
            }

            listing.assets.push(
                Asset({
                    assetType: asset.assetType,
                    tokenAddress: asset.tokenAddress,
                    tokenId: asset.tokenId,
                    amount: asset.amount
                })
            );
        }

        emit Listed(listId, msg.sender, assets, price, description);
    }

    function buy(uint256 listId) external payable nonReentrant {
        TradeableAssetPackage memory listing = listed[listId];
        require(listing.owner != address(0), "OnChainExchange: listing must exist");
        require(listing.owner != msg.sender, "OnChainExchange: cannot buy own listing");
        require(msg.value == listing.price, "OnChainExchange: must send exact price");

        for (uint256 i = 0; i < listing.assets.length; i++) {
            Asset memory asset = listing.assets[i];

            if (asset.assetType == AssetType.ERC20) {
                IERC20(asset.tokenAddress).transferFrom(address(this), msg.sender, asset.amount);
            } else if (asset.assetType == AssetType.ERC721) {
                IERC721(asset.tokenAddress).safeTransferFrom(address(this), msg.sender, asset.tokenId);
            } else if (asset.assetType == AssetType.ERC1155) {
                IERC1155(asset.tokenAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    asset.tokenId,
                    asset.amount,
                    ""
                );
            } else {
                revert("OnChainExchange: invalid asset type");
            }
        }

        payable(listing.owner).transfer(msg.value);

        delete listed[listId];

        emit Bought(listId, msg.sender);
    }

    function cancel(uint256 listId) external {
        TradeableAssetPackage memory listing = listed[listId];
        require(listing.owner != address(0), "OnChainExchange: listing must exist");
        require(listing.owner == msg.sender, "OnChainExchange: cannot cancel another's listing");

        for (uint256 i = 0; i < listing.assets.length; i++) {
            Asset memory asset = listing.assets[i];

            if (asset.assetType == AssetType.ERC20) {
                IERC20(asset.tokenAddress).transferFrom(address(this), msg.sender, asset.amount);
            } else if (asset.assetType == AssetType.ERC721) {
                IERC721(asset.tokenAddress).safeTransferFrom(address(this), msg.sender, asset.tokenId);
            } else if (asset.assetType == AssetType.ERC1155) {
                IERC1155(asset.tokenAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    asset.tokenId,
                    asset.amount,
                    ""
                );
            } else {
                revert("OnChainExchange: invalid asset type");
            }
        }

        delete listed[listId];

        emit Cancelled(listId);
    }
}
