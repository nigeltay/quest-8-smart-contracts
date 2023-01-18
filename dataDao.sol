// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

contract DataDao {
    address payable public seller;
    string public title;
    string public description;
    uint256 public price;
    string public CID;
    address[] public buyers;
    uint256 public amountStored;

    constructor(
        address payable _seller,
        string memory _title,
        string memory _description,
        uint256 _price,
        string memory _CID
    ) {
        seller = _seller;
        title = _title;
        description = _description;
        price = _price;
        CID = _CID;
    }

    function buyDataSet() external payable returns (bool) {
        require(msg.sender != seller);
        require(msg.value == price);
        buyers.push(msg.sender);
        amountStored = amountStored + price;
        emit BuyDataset(msg.sender);
        return true;
    }

    function withdrawFunds() external returns (bool) {
        require(msg.sender == seller);
        seller.transfer(amountStored);
        emit WithdrawFunds(amountStored);
        amountStored = 0;
        return true;
    }

    function getDetailInformation()
        public
        view
        returns (
            address[] memory _buyers,
            uint256 _amountStored,
            string memory _CID
        )
    {
        return (buyers, amountStored, CID);
    }

    event BuyDataset(address user);
    event WithdrawFunds(uint256 amount);
}
