// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

// Abstract
interface USDC {
    function balanceOf(address account) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Campaign {
    address public proposer;
    string public title;
    string public description;
    uint256 public targetAmount;
    address[] public contributorAddresses;
    int256[] public contributions;
    mapping(address => bool) contributorList;
    uint256 public campaignDeadline;
    CampaignState public status;
    USDC public USDc;
    address usdcAvaxAddress = 0x5425890298aed601595a70AB815c96711a31Bc65;
    address usdcEthAddress = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;

    enum CampaignState {
        LIVE,
        SUCCESS,
        ENDED,
        CLOSED
    }

    constructor(
        address _proposer,
        string memory _title,
        string memory _description,
        uint256 _targetAmount,
        uint256 _campaignDeadline
    ) {
        require(_campaignDeadline > block.timestamp);
        proposer = _proposer;
        title = _title;
        description = _description;
        status = CampaignState.LIVE;
        targetAmount = _targetAmount;
        campaignDeadline = _campaignDeadline;
        USDc = USDC(usdcEthAddress);
    }

    function deposit(uint256 _depositAmount, address _depositAddress) external {
        require(campaignDeadline > block.timestamp);
        require(USDc.balanceOf(_depositAddress) > _depositAmount);

        USDc.transferFrom(_depositAddress, address(this), _depositAmount);
        contributorAddresses.push(_depositAddress);
        contributions.push(int(_depositAmount));
        contributorList[_depositAddress] = true;
        if (USDc.balanceOf(address(this)) > targetAmount) {
            status = CampaignState.SUCCESS;
        }
    }

    function refund(address _refundAddress) external {
        require(contributorList[_refundAddress]);
        require(status == CampaignState.LIVE);
        require(campaignDeadline > block.timestamp);
        uint256 userContribution = getContributionAmount(_refundAddress);
        require(userContribution > 0);
        USDc.transfer(_refundAddress, userContribution);
        contributorAddresses.push(_refundAddress);
        contributions.push(-int(userContribution));
        contributorList[_refundAddress] = false;
    }

    function withdraw(address _withdrawAddress) external {
        require(proposer == _withdrawAddress);
        require(block.timestamp > campaignDeadline);

        USDc.transfer(proposer, USDc.balanceOf(address(this)));

        status = CampaignState.CLOSED;
    }

    function getContributionAmount(
        address _userWallet
    ) public view returns (uint256) {
        if (contributorList[_userWallet] == false) {
            return 0;
        }
        int256 totalContributions = 0;
        for (uint256 i = 0; i < contributorAddresses.length; i++) {
            if (contributorAddresses[i] == _userWallet) {
                totalContributions = totalContributions + contributions[i];
            }
        }
        return uint(totalContributions);
    }

    function hasContributed(
        address _walletAddress
    ) external view returns (bool) {
        return contributorList[_walletAddress];
    }

    function getStatus() external view returns (string memory _status) {
        if (status == CampaignState.SUCCESS) {
            return "Success";
        } else if (status == CampaignState.LIVE) {
            return "Live";
        } else if (block.timestamp > campaignDeadline) {
            return "Ended";
        } else {
            return "Closed";
        }
    }

    function getTotalContributions() external view returns (uint256) {
        return USDc.balanceOf(address(this));
    }
}
