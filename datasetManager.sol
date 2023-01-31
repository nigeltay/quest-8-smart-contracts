// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./dataset.sol";

contract DatasetManager {
    uint256 datasetIDCounter;
    Dataset[] public datasetList;
    mapping(address => uint256) public datasetIDs;

    function createDataset(
        string memory _title,
        string memory _description,
        uint256 _price,
        string memory _CID
    ) external returns (bool) {
        uint256 datasetID = datasetIDCounter;
        datasetIDCounter++;
        Dataset dataset = new Dataset(
            payable(msg.sender),
            _title,
            _description,
            _price,
            _CID
        );
        datasetList.push(dataset);
        datasetIDs[address(dataset)] = datasetID;
        return true;
    }

    function getDatasetList()
        external
        view
        returns (address[] memory _datasetList)
    {
        _datasetList = new address[](datasetIDCounter);
        for (uint256 i = 0; i < datasetIDCounter; i++) {
            _datasetList[i] = address(datasetList[i]);
        }
        return _datasetList;
    }

    function getDatasetInformation(address[] calldata _datasetList)
        external
        view
        returns (
            address[] memory sellerAddress,
            string[] memory title,
            string[] memory description,
            uint256[] memory price
        )
    {
        sellerAddress = new address[](_datasetList.length);
        title = new string[](_datasetList.length);
        description = new string[](_datasetList.length);
        price = new uint256[](_datasetList.length);

        for (uint256 i = 0; i < _datasetList.length; i++) {
            uint256 datasetID = datasetIDs[_datasetList[i]];
            sellerAddress[i] = datasetList[datasetID].seller();
            title[i] = datasetList[datasetID].title();
            description[i] = datasetList[datasetID].description();
            price[i] = datasetList[datasetID].price();
        }
        return (sellerAddress, title, description, price);
    }
}
