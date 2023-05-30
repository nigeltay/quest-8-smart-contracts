// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./treasury.sol";

contract TreasuryManager {
    uint256 treasuryIDCounter;
    Treasury[] public treasuries;
    mapping(address => uint256) public treasuryIDs;

    function createTreasury(
        string memory _title,
        string memory _description,
        address _depositAddress,
        string memory _walletID
    ) external {
        uint256 treasuryID = treasuryIDCounter;
        treasuryIDCounter++;
        Treasury treasury = new Treasury(
            _title,
            _description,
            _depositAddress,
            _walletID
        );
        treasuries.push(treasury);
        treasuryIDs[address(treasury)] = treasuryID;
    }

    function getTresuries()
        external
        view
        returns (address[] memory _treasuryAddresses)
    {
        _treasuryAddresses = new address[](treasuryIDCounter);
        for (uint256 i = 0; i < treasuryIDCounter; i++) {
            _treasuryAddresses[i] = address(treasuries[i]);
        }
        return _treasuryAddresses;
    }

    function getTreasuriesData(
        address[] calldata _treasuryList
    )
        external
        view
        returns (string[] memory title, string[] memory description)
    {
        title = new string[](_treasuryList.length);
        description = new string[](_treasuryList.length);
        for (uint256 i = 0; i < _treasuryList.length; i++) {
            uint256 treasuryID = treasuryIDs[_treasuryList[i]];
            Treasury treasury = treasuries[treasuryID];
            title[i] = treasury.title();
            description[i] = treasury.description();
        }
        return (title, description);
    }

    function hasJoinedTreasury(
        address _treasuryAddress
    ) external view returns (bool) {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        Treasury treasury = treasuries[treasuryID];
        return treasury.hasJoinedTreasury(msg.sender);
    }

    function joinTreasury(address _treasuryAddress) external {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        Treasury treasury = treasuries[treasuryID];
        treasury.joinTreasury(msg.sender);
    }

    function voteOnWithdrawProposal(
        address _treasuryAddress,
        address _proposalAddress,
        bool _isVoteYes
    ) external {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        Treasury treasury = treasuries[treasuryID];
        treasury.voteOnWithdrawProposal(
            msg.sender,
            _proposalAddress,
            _isVoteYes
        );
    }

    function hasVoted(
        address _treasuryAddress,
        address _proposalAddress
    ) external view returns (bool) {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        Treasury treasury = treasuries[treasuryID];
        return treasury.hasVoted(_proposalAddress, msg.sender);
    }

    function getProposals(
        address _treasuryAddress
    ) external view returns (address[] memory _proposalAddresses) {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        Treasury treasury = treasuries[treasuryID];
        return treasury.getProposals();
    }

    function getProposalOverviewData(
        address _treasuryAddress,
        address[] calldata _proposalList
    )
        external
        view
        returns (
            address[] memory proposerAddress,
            string[] memory proposalTitle,
            string[] memory proposalDescription,
            string[] memory status,
            uint256[] memory withdrawAmount,
            uint256[] memory numberOfYesVotes,
            uint256[] memory numberOfNoVotes
        )
    {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        Treasury treasury = treasuries[treasuryID];
        return treasury.getProposalData(_proposalList);
    }
}
