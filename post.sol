// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

contract Post {
    address public poster;
    mapping(address => bool) public upvotes;
    address[] public upvoteList;
    address[] public commentIDs;
    uint256[] public commentTimeStamps;

    constructor(address _poster) {
        poster = _poster;
    }

    function postComment(address _commenter, uint256 _timeStamp)
        public
        returns (bool)
    {
        commentIDs.push(_commenter);
        commentTimeStamps.push(_timeStamp);
        emit PostComment(_commenter);
        return true;
    }

    function upvotePost() external returns (bool) {
        if (upvotes[msg.sender] != true) {
            upvoteList.push(msg.sender);
            upvotes[msg.sender] = true;
            emit UpvotePost(msg.sender);
        }
        return true;
    }

    function upvoteListLength() public view returns (uint256) {
        return upvoteList.length;
    }

    function commentListLength() public view returns (uint256) {
        return commentIDs.length;
    }

    function getDetailedPostInformation()
        public
        view
        returns (
            address[] memory _upvoteList,
            address[] memory _commentIDs,
            uint256[] memory _commentTimeStamps
        )
    {
        return (upvoteList, commentIDs, commentTimeStamps);
    }

    event UpvotePost(address user);
    event PostComment(address user);
}
