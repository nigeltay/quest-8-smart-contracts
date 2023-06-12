// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./campaign.sol";

contract CampaignManager {
    Campaign[] public campaigns;
    mapping(address => uint256) public campaignIDs;

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _targetAmount,
        uint64 _campaignDeadline
    ) external {
        uint256 campaignID = campaigns.length;
        Campaign campaign = new Campaign(
            msg.sender,
            _title,
            _description,
            _targetAmount,
            _campaignDeadline
        );
        campaigns.push(campaign);
        campaignIDs[address(campaign)] = campaignID;
    }

    function getCampaigns()
        external
        view
        returns (address[] memory _campaignAddresses)
    {
        _campaignAddresses = new address[](campaigns.length);
        for (uint256 i = 0; i < campaigns.length; i++) {
            _campaignAddresses[i] = address(campaigns[i]);
        }
        return _campaignAddresses;
    }

    function getCampaignData(
        address[] calldata _campaignList
    )
        external
        view
        returns (
            string[] memory title,
            string[] memory description,
            uint256[] memory targetAmount,
            uint256[] memory currentAmount
        )
    {
        title = new string[](_campaignList.length);
        description = new string[](_campaignList.length);
        targetAmount = new uint256[](_campaignList.length);
        currentAmount = new uint256[](_campaignList.length);
        for (uint256 i = 0; i < _campaignList.length; i++) {
            uint256 campaignID = campaignIDs[_campaignList[i]];
            Campaign campaign = campaigns[campaignID];
            title[i] = campaign.title();
            description[i] = campaign.description();
            targetAmount[i] = campaign.targetAmount();
            currentAmount[i] = campaign.getTotalContributions();
        }
        return (title, description, targetAmount, currentAmount);
    }

    function hasContributed(
        address _accountAddress
    ) external view returns (bool) {
        uint256 campaignID = campaignIDs[_accountAddress];
        return campaigns[campaignID].hasContributed(msg.sender);
    }

    function deposit(
        uint256 _depositAmount,
        address _campaignAddress
    ) external {
        uint256 campaignID = campaignIDs[_campaignAddress];
        return campaigns[campaignID].deposit(_depositAmount, msg.sender);
    }

    function fund(
        uint256 _refundAmount,
        address _campaignAddress,
        bool _refundToAvax
    ) external {
        uint256 campaignID = campaignIDs[_campaignAddress];
        if (_refundToAvax) {
            campaigns[campaignID].refundToAvax(_refundAmount, msg.sender);
        } else {
            campaigns[campaignID].refund(_refundAmount, msg.sender);
        }
    }
}
