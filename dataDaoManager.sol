// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./dataDao.sol";

contract DataDaoManager {
    uint256 dataDaoIDCounter;
    DataDao[] public dataDaoList;
    mapping(address => uint256) public dataDaoIDs;

    function createDataDao(
        string memory _title,
        string memory _description,
        uint256 _price,
        string memory _CID
    ) external returns (bool) {
        uint256 dataDaoID = dataDaoIDCounter;
        dataDaoIDCounter++;
        DataDao dataDao = new DataDao(
            payable(msg.sender),
            _title,
            _description,
            _price,
            _CID
        );
        dataDaoList.push(dataDao);
        dataDaoIDs[address(dataDao)] = dataDaoID;
        return true;
    }

    function getDataDaoList()
        external
        view
        returns (address[] memory _dataDaoList)
    {
        _dataDaoList = new address[](dataDaoIDCounter);
        for (uint256 i = 0; i < dataDaoIDCounter; i++) {
            _dataDaoList[i] = address(_dataDaoList[i]);
        }
        return _dataDaoList;
    }

    function getDataDaoInformation(address[] calldata _dataDaoList)
        external
        view
        returns (
            address[] memory sellerAddress,
            string[] memory title,
            string[] memory description,
            uint256[] memory price
        )
    {
        sellerAddress = new address[](_dataDaoList.length);
        title = new string[](_dataDaoList.length);
        description = new string[](_dataDaoList.length);
        price = new uint256[](_dataDaoList.length);

        for (uint256 i = 0; i < _dataDaoList.length; i++) {
            uint256 dataDaoID = dataDaoIDs[_dataDaoList[i]];
            sellerAddress[i] = dataDaoList[dataDaoID].seller();
            title[i] = dataDaoList[dataDaoID].title();
            description[i] = dataDaoList[dataDaoID].description();
            price[i] = dataDaoList[dataDaoID].price();
        }
        return (sellerAddress, title, description, price);
    }
}
