// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./treasury.sol";

contract TreasuryManager {
    Treasury[] public treasuries;
    mapping(address => uint256) public treasuryIDs;

    function createTreasury(
        string memory _title,
        string memory _description,
        address _depositAddress,
        string memory _walletID
    ) external {
        uint256 treasuryID = treasuries.length;
        Treasury treasury = new Treasury(
            _title,
            _description,
            _depositAddress,
            _walletID
        );
        treasuries.push(treasury);
        treasuryIDs[address(treasury)] = treasuryID;
    }

    function getTreasuries()
        external
        view
        returns (address[] memory _treasuryAddresses)
    {
        _treasuryAddresses = new address[](treasuries.length);
        for (uint256 i = 0; i < treasuries.length; i++) {
            _treasuryAddresses[i] = address(treasuries[i]);
        }
        return _treasuryAddresses;
    }

    function getTreasuriesData(
        address[] calldata _treasuryList
    )
        external
        view
        returns (
            string[] memory title,
            string[] memory description,
            address[] memory depositAddress,
            string[] memory walletID
        )
    {
        title = new string[](_treasuryList.length);
        description = new string[](_treasuryList.length);
        depositAddress = new address[](_treasuryList.length);
        walletID = new string[](_treasuryList.length);
        for (uint256 i = 0; i < _treasuryList.length; i++) {
            uint256 treasuryID = treasuryIDs[_treasuryList[i]];
            Treasury treasury = treasuries[treasuryID];
            title[i] = treasury.title();
            description[i] = treasury.description();
            depositAddress[i] = treasury.depositAddress();
            walletID[i] = treasury.depositWalletID();
        }
        return (title, description, depositAddress, walletID);
    }

    function hasJoinedTreasury(
        address _treasuryAddress,
        address _userWallet
    ) external view returns (bool) {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        return treasuries[treasuryID].members(_userWallet);
    }

    function joinTreasury(
        address _treasuryAddress,
        address _userWallet
    ) external {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        treasuries[treasuryID].joinTreasury(_userWallet);
    }

    function voteOnWithdrawProposal(
        address _treasuryAddress,
        address _proposalAddress,
        bool _isVoteYes,
        address _userWallet
    ) external returns (bool) {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        return
            treasuries[treasuryID].voteOnWithdrawProposal(
                _userWallet,
                _proposalAddress,
                _isVoteYes
            );
    }

    function hasVoted(
        address _treasuryAddress,
        address _proposalAddress,
        address _userWallet
    ) external view returns (bool) {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        return treasuries[treasuryID].hasVoted(_proposalAddress, _userWallet);
    }

    function createWithdrawProposal(
        address _treasuryAddress,
        string memory _title,
        string memory _description,
        uint256 _withdrawAmount,
        address _withdrawWallet,
        address _userWallet
    ) external {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        treasuries[treasuryID].createWithdrawProposal(
            _userWallet,
            _title,
            _description,
            _withdrawAmount,
            _withdrawWallet
        );
    }

    function getProposals(
        address _treasuryAddress
    ) external view returns (address[] memory _proposalAddresses) {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        return treasuries[treasuryID].getProposals();
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
            uint256[] memory numberOfNoVotes,
            address[] memory withdrawWallet
        )
    {
        uint256 treasuryID = treasuryIDs[_treasuryAddress];
        return treasuries[treasuryID].getProposalData(_proposalList);
    }
}
