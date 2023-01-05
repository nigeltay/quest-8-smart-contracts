// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./groupBuy.sol";

contract GroupBuyManager {
    uint256 _groupBuyIDCounter; // group buy Id counter
    GroupBuy[] public groupBuys; // Holds the group buy reference objects to the group buy objects
    mapping(address => uint256) public groupBuysIDs; // maps the groupbuy smart contract addres to its ID

    // create an group buy
    function createGroupbuy(
        uint256 _endTime,
        uint256 _price,
        string calldata _productName,
        string calldata _productDescription
    ) external returns (bool) {
        require(_price > 0); // direct buy price must be greater than 0
        require(_endTime > 5 minutes);
        // end time must be greater than 5 minutes

        uint256 groupBuyID = _groupBuyIDCounter; // get the current value of the counter
        _groupBuyIDCounter++; // increment the counter
        GroupBuy groupBuy = new GroupBuy(
            msg.sender,
            _endTime,
            _price,
            _productName,
            _productDescription
        ); // create the groupbuy
        groupBuys.push(groupBuy);
        groupBuysIDs[address(groupBuy)] = groupBuyID; // add the groupbuy to the map
        return true;
    }

    // Return a list of all group buys
    function getGroupBuys()
        external
        view
        returns (address[] memory _groupBuys)
    {
        // create an array of size equal to the current value of the counter
        _groupBuys = new address[](_groupBuyIDCounter);
        for (uint256 i = 0; i < _groupBuyIDCounter; i++) {
            // add the address of the group buy to the array
            _groupBuys[i] = address(groupBuys[i]);
        }
        return _groupBuys; // return the array
    }

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
        // create an array of size equal to the length of the passed array
        endTime = new uint256[](_groupBuyList.length);
        price = new uint256[](_groupBuyList.length);
        seller = new address[](_groupBuyList.length);
        productName = new string[](_groupBuyList.length);
        productDescription = new string[](_groupBuyList.length);
        groupBuyState = new uint256[](_groupBuyList.length);

        for (uint256 i = 0; i < _groupBuyList.length; i++) {
            uint256 groupBuyID = groupBuysIDs[_groupBuyList[i]];
            // get the product name
            productName[i] = groupBuys[groupBuyID].productName();
            // get the owner of the group buy
            productDescription[i] = groupBuys[groupBuyID].productDescription();
            // get the product price
            price[i] = groupBuys[groupBuyID].price();
            // get the seller wallet address
            seller[i] = groupBuys[groupBuyID].seller();
            groupBuyState[i] = uint256(
                groupBuys[groupBuyID].getGroupBuyState()
            ); // get the group buy state
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
