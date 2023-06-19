// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./account.sol";

contract AccountManager {
    Account[] public accounts;
    mapping(address => uint256) public accountIDs;

    function createAccount(
        string memory _title,
        string memory _description,
        address _depositAddress,
        string memory _walletID
    ) external {
        uint256 accountID = accounts.length;
        Account account = new Account(
            _title,
            _description,
            _depositAddress,
            _walletID
        );
        accounts.push(account);
        accountIDs[address(account)] = accountID;
    }

    function getAccounts()
        external
        view
        returns (address[] memory _accountAddresses)
    {
        _accountAddresses = new address[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!accounts[i].isDeleted()) {
                _accountAddresses[i] = address(accounts[i]);
            }
        }
        return _accountAddresses;
    }

    function getAccountsData(
        address[] calldata _treasuryList
    )
        external
        view
        returns (
            string[] memory title,
            string[] memory description,
            address[] memory depositAddress,
            string[] memory walletID,
            bool[] memory isDeleted
        )
    {
        title = new string[](_treasuryList.length);
        description = new string[](_treasuryList.length);
        depositAddress = new address[](_treasuryList.length);
        walletID = new string[](_treasuryList.length);
        isDeleted = new bool[](_treasuryList.length);
        for (uint256 i = 0; i < _treasuryList.length; i++) {
            uint256 accountID = accountIDs[_treasuryList[i]];
            Account account = accounts[accountID];
            title[i] = account.title();
            description[i] = account.description();
            depositAddress[i] = account.depositAddress();
            walletID[i] = account.depositWalletID();
            isDeleted[i] = account.isDeleted();
        }
        return (title, description, depositAddress, walletID, isDeleted);
    }

    function hasJoinedAccount(
        address _accountAddress,
        address _userWallet
    ) external view returns (bool) {
        uint256 accountID = accountIDs[_accountAddress];
        return accounts[accountID].members(_userWallet);
    }

    function joinAccount(
        address _accountAddress,
        address _userWallet
    ) external {
        uint256 accountID = accountIDs[_accountAddress];
        accounts[accountID].joinAccount(_userWallet);
    }

    function voteOnWithdrawProposal(
        address _accountAddress,
        address _proposalAddress,
        bool _isVoteYes,
        address _userWallet
    ) external returns (bool) {
        uint256 accountID = accountIDs[_accountAddress];
        return
            accounts[accountID].voteOnWithdrawProposal(
                _userWallet,
                _proposalAddress,
                _isVoteYes
            );
    }

    function hasVoted(
        address _accountAddress,
        address _proposalAddress,
        address _userWallet
    ) external view returns (bool) {
        uint256 accountID = accountIDs[_accountAddress];
        return accounts[accountID].hasVoted(_proposalAddress, _userWallet);
    }

    function createWithdrawProposal(
        address _accountAddress,
        string memory _title,
        string memory _description,
        uint256 _withdrawAmount,
        address _withdrawWallet,
        address _userWallet
    ) external {
        uint256 accountID = accountIDs[_accountAddress];
        accounts[accountID].createWithdrawProposal(
            _userWallet,
            _title,
            _description,
            _withdrawAmount,
            _withdrawWallet
        );
    }

    function getProposals(
        address _accountAddress
    ) external view returns (address[] memory _proposalAddresses) {
        uint256 accountID = accountIDs[_accountAddress];
        return accounts[accountID].getProposals();
    }

    function getProposalOverviewData(
        address _accountAddress,
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
        uint256 accountID = accountIDs[_accountAddress];
        return accounts[accountID].getProposalData(_proposalList);
    }

    function deleteAccount(address _accountAddress) external {
        uint256 accountID = accountIDs[_accountAddress];
        accounts[accountID].deleteAccount(_accountAddress);
    }
}
