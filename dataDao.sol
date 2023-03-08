// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./tradingProposal.sol";
import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";

contract DataDao {
    address[] public members;
    mapping(address => bool) membersList;
    string private datasetCID;
    TradingProposal[] public tradingProposals;
    mapping(address => uint256) public tradingProposalsList;
    string public test;

    constructor(string memory _datasetCID) {
        datasetCID = _datasetCID;
        membersList[msg.sender] = true;
        members.push(msg.sender);
    }

    function checkIfMember() external view returns (bool) {
        return membersList[msg.sender];
    }

    function joinDataDao() external {
        require(membersList[msg.sender] != true);
        members.push(msg.sender);
        membersList[msg.sender] = true;
        emit NewMember(msg.sender, members.length - 1);
    }

    function createTradingProposal(
        string memory title,
        string memory description
    ) external {
        require(members[0] == msg.sender);
        MarketTypes.GetDealDataCommitmentReturn
            memory dealDataCommitment = MarketAPI.getDealDataCommitment(967);
        if (dealDataCommitment.size > 0) {
            TradingProposal newTradingProposal = new TradingProposal(
                msg.sender,
                title,
                description,
                datasetCID
            );
            tradingProposals.push(newTradingProposal);
            tradingProposalsList[address(newTradingProposal)] =
                tradingProposals.length -
                1;
        }
    }

    function vote(address tradingProposalAddress, bool isYesVote) external {
        require(membersList[msg.sender] == true);
        uint256 tradingProposalId = tradingProposalsList[
            tradingProposalAddress
        ];
        TradingProposal tradingProposal = tradingProposals[tradingProposalId];
        tradingProposal.vote(msg.sender, isYesVote);
    }

    function getTradingProposalCID(address tradingProposalAddress)
        external
        view
        returns (string memory _cid)
    {
        require(membersList[msg.sender] == true);
        uint256 tradingProposalId = tradingProposalsList[
            tradingProposalAddress
        ];
        TradingProposal tradingProposal = tradingProposals[tradingProposalId];
        return tradingProposal.getDataSetCID();
    }

    function getTradingProposalList()
        external
        view
        returns (
            string[] memory title,
            string[] memory description,
            string[] memory status,
            address[] memory tradingProposalContractAddress
        )
    {
        title = new string[](tradingProposals.length);
        description = new string[](tradingProposals.length);
        status = new string[](tradingProposals.length);
        tradingProposalContractAddress = new address[](tradingProposals.length);

        for (uint256 i = 0; i < tradingProposals.length; i++) {
            title[i] = tradingProposals[i].title();
            description[i] = tradingProposals[i].description();
            status[i] = tradingProposals[i].getStatus();
            tradingProposalContractAddress[i] = address(tradingProposals[i]);
        }
        return (title, description, status, tradingProposalContractAddress);
    }

    function getDetailedTradingProposalInfo(address _tradingProposalList)
        external
        view
        returns (
            address _proposer,
            uint256 _numberOfYesVotes,
            uint256 _numberOfNoVotes,
            uint256 _voteThreshold,
            string memory _cid
        )
    {
        require(membersList[msg.sender] == true);
        uint256 tradingProposalId = tradingProposalsList[_tradingProposalList];
        TradingProposal tradingProposal = tradingProposals[tradingProposalId];
        return (
            tradingProposal.proposer(),
            tradingProposal.getNumberOfYesVotes(),
            tradingProposal.getNumberOfNoVotes(),
            tradingProposal.voteThreshold(),
            tradingProposal.getDataSetCID()
        );
    }

    event NewMember(address memberAddress, uint256 id);
}
