// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./groupBuy.sol";

contract GroupBuyManager {
    uint256 _groupBuyIDCounter; // auction Id counter
    mapping(uint256 => GroupBuy) public groupBuys; // auctions

    // create an auction
    function createGroupbuy(
        uint256 _endTime,
        uint256 _price,
        string calldata _productName,
        string calldata _productDescription
    ) external returns (bool) {
        require(_price > 0); // direct buy price must be greater than 0
        require(_endTime > 5 minutes); // end time must be greater than 5 minutes (setting it to 5 minutes for testing you can set it to 1 days or anything you would like)

        uint256 groupBuyID = _groupBuyIDCounter; // get the current value of the counter
        _groupBuyIDCounter++; // increment the counter
        GroupBuy groupBuy = new GroupBuy(
            msg.sender,
            _endTime,
            _price,
            _productName,
            _productDescription
        ); // create the auction

        groupBuys[groupBuyID] = groupBuy; // add the auction to the map
        return true;
    }

    // Return a list of all auctions
    function getGroupBuys()
        external
        view
        returns (address[] memory _groupBuys)
    {
        _groupBuys = new address[](_groupBuyIDCounter); // create an array of size equal to the current value of the counter
        for (uint256 i = 0; i < _groupBuyIDCounter; i++) {
            // for each auction
            _groupBuys[i] = address(groupBuys[i]); // add the address of the auction to the array
        }
        return _groupBuys; // return the array
    }

    // Return the information of each auction address
    function getGroupBuyInfo(address[] calldata _groupBuyList)
        external
        view
        returns (
            string[] memory productName,
            string[] memory productDescription,
            uint256[] memory price,
            address[] memory seller,
            uint256[] memory endTime,
            uint256[] memory groupBuyState
        )
    {
        endTime = new uint256[](_groupBuyList.length); // create an array of size equal to the length of the passed array
        price = new uint256[](_groupBuyList.length); // create an array of size equal to the length of the passed array
        seller = new address[](_groupBuyList.length);
        productName = new string[](_groupBuyList.length);
        productDescription = new string[](_groupBuyList.length);
        groupBuyState = new uint256[](_groupBuyList.length);

        for (uint256 i = 0; i < _groupBuyList.length; i++) {
            // for each auction
            productName[i] = GroupBuy(groupBuys[i]).productName(); // get the direct buy price
            productDescription[i] = GroupBuy(groupBuys[i]).productDescription(); // get the owner of the auction
            price[i] = GroupBuy(groupBuys[i]).price(); // get the highest bid
            seller[i] = GroupBuy(groupBuys[i]).seller(); // get the token id
            endTime[i] = GroupBuy(groupBuys[i]).endTime(); // get the end time
            groupBuyState[i] = uint256(
                GroupBuy(groupBuys[i]).getGroupBuyState()
            ); // get the auction state
        }

        return (
            // return the arrays
            productName,
            productDescription,
            price,
            seller,
            endTime,
            groupBuyState
        );
    }
}
