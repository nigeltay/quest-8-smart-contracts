// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./withdrawProposal.sol";

contract Account {
    uint256 proposalIDCounter;
    WithdrawProposal[] public withdrawProposals;
    mapping(address => uint256) public proposalIDs;
    string public title;
    string public description;
    address[] public membersList;
    mapping(address => bool) public members;
    address public depositAddress;
    string public depositWalletID;

    constructor(
        string memory _title,
        string memory _description,
        address _depositAddress,
        string memory _walletID
    ) {
        title = _title;
        description = _description;
        depositAddress = _depositAddress;
        depositWalletID = _walletID;
    }

    function createWithdrawProposal(
        address _proposer,
        string memory _title,
        string memory _description,
        uint256 _withdrawAmount,
        address _withdrawWallet
    ) external {
        require(_proposer != address(this));
        uint256 proposalID = proposalIDCounter;
        proposalIDCounter++;
        WithdrawProposal proposal = new WithdrawProposal(
            _proposer,
            _title,
            _description,
            _withdrawAmount,
            _withdrawWallet
        );
        withdrawProposals.push(proposal);
        proposalIDs[address(proposal)] = proposalID;
    }

    function joinAccount(address _address) external {
        require(members[_address] == false);
        membersList.push(_address);
        members[_address] = true;
    }

    function hasJoinedAccount(address _address) external view returns (bool) {
        return members[_address];
    }

    function voteOnWithdrawProposal(
        address _voter,
        address _proposalAddress,
        bool _isVoteYes
    ) external returns (bool) {
        require(members[_voter] == true);
        uint256 proposalID = proposalIDs[_proposalAddress];
        return withdrawProposals[proposalID].vote(_voter, _isVoteYes);
    }

    function hasVoted(
        address _proposalAddress,
        address _userAddress
    ) external view returns (bool) {
        uint256 proposalID = proposalIDs[_proposalAddress];
        return withdrawProposals[proposalID].hasVoted(_userAddress);
    }

    function getProposals()
        external
        view
        returns (address[] memory _proposalAddresses)
    {
        _proposalAddresses = new address[](proposalIDCounter);
        for (uint256 i = 0; i < proposalIDCounter; i++) {
            _proposalAddresses[i] = address(withdrawProposals[i]);
        }
        return _proposalAddresses;
    }

    function getProposalData(
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
        proposerAddress = new address[](_proposalList.length);
        proposalTitle = new string[](_proposalList.length);
        proposalDescription = new string[](_proposalList.length);
        status = new string[](_proposalList.length);
        withdrawAmount = new uint256[](_proposalList.length);
        numberOfYesVotes = new uint256[](_proposalList.length);
        numberOfNoVotes = new uint256[](_proposalList.length);
        withdrawWallet = new address[](_proposalList.length);
        for (uint256 i = 0; i < _proposalList.length; i++) {
            uint256 proposalID = proposalIDs[_proposalList[i]];
            WithdrawProposal proposal = withdrawProposals[proposalID];
            proposerAddress[i] = proposal.proposer();
            proposalTitle[i] = proposal.title();
            proposalDescription[i] = proposal.description();
            status[i] = proposal.getStatus();
            withdrawAmount[i] = proposal.withdrawAmount();
            numberOfYesVotes[i] = proposal.getNumberOfYesVotes();
            numberOfNoVotes[i] = proposal.getNumberOfNoVotes();
            withdrawWallet[i] = proposal.withdrawWallet();
        }
        return (
            proposerAddress,
            proposalTitle,
            proposalDescription,
            status,
            withdrawAmount,
            numberOfYesVotes,
            numberOfNoVotes,
            withdrawWallet
        );
    }
}
