// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

contract Dataset {
    address payable public seller;
    string public title;
    string public description;
    uint256 public price;
    string private CID;
    address[] public buyers;
    mapping(address => bool) buyersList;

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
        require(buyersList[msg.sender] != true);
        buyers.push(msg.sender);
        buyersList[msg.sender] = true;
        emit BuyDataset(msg.sender);
        return true;
    }

    function withdrawFunds() external returns (bool) {
        require(msg.sender == seller);
        uint256 amountStored = address(this).balance;
        emit WithdrawFunds(amountStored);
        seller.transfer(amountStored);
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
        _amountStored = 0;
        _CID = CID;
        if (msg.sender == seller) {
            _amountStored = address(this).balance;
        }
        if (buyersList[msg.sender] != true) {
            _CID = "Access Denied! Not a Buyer!";
        }
        return (buyers, _amountStored, _CID);
    }

    event BuyDataset(address user);
    event WithdrawFunds(uint256 amount);
}
