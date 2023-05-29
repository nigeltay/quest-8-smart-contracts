// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

contract WithdrawProposal {
    address public proposer;
    string public title;
    string public description;
    uint256 public voteThreshold;
    uint256 public withdrawAmount;
    WithdrawProposalState public status;
    address[] public yesVoters;
    mapping(address => bool) public yesVotersList;
    address[] public noVoters;
    mapping(address => bool) public noVotersList;
    address private parentContract;

    enum WithdrawProposalState {
        VOTING,
        SUCCESS,
        FAIL
    }

    constructor(
        address _proposer,
        string memory _title,
        string memory _description,
        uint256 _withdrawAmount,
        address parentAddress
    ) {
        proposer = _proposer;
        title = _title;
        description = _description;
        voteThreshold = 2;
        status = WithdrawProposalState.VOTING;
        withdrawAmount = _withdrawAmount;
        parentContract = parentAddress;
    }

    function hasVoted(address _voter) public view returns (bool) {
        // require(parent == msg.sender);
        return yesVotersList[_voter] || noVotersList[_voter];
    }

    function vote(address _voter, bool isVoteYes) public returns (bool) {
        require(parentContract == msg.sender);
        require(status == WithdrawProposalState.VOTING);
        require(yesVotersList[_voter] != true);
        require(noVotersList[_voter] != true);
        require(_voter != proposer);
        if (isVoteYes) {
            yesVoters.push(_voter);
            yesVotersList[_voter] = true;
            if (yesVoters.length == voteThreshold) {
                status = WithdrawProposalState.SUCCESS;
                return true;
            }
        } else {
            noVoters.push(_voter);
            noVotersList[_voter] = true;
            if (noVoters.length == voteThreshold) {
                status = WithdrawProposalState.FAIL;
            }
        }
        return false;
    }

    function getStatus() public view returns (string memory _status) {
        if (status == WithdrawProposalState.SUCCESS) {
            return "Success";
        } else if (status == WithdrawProposalState.FAIL) {
            return "Failed";
        } else {
            return "Voting";
        }
    }

    function getNumberOfYesVotes() public view returns (uint256 _yesVotes) {
        return yesVoters.length;
    }

    function getNumberOfNoVotes() public view returns (uint256 _noVotes) {
        return noVoters.length;
    }
}
