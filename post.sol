// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

contract Post {
    address public poster;
    mapping(address => bool) public likes; //Map user to true.
    address[] public likeList;
    address[] public commentIDs; //Map user to comments.
    uint256[] public commentTimeStamps; //Map Comment ID to timestamp

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

    function likePost() external returns (bool) {
        if (likes[msg.sender] != true) {
            likeList.push(msg.sender);
            emit LikePost(msg.sender);
        }
        likes[msg.sender] = true;
        return true;
    }

    function likeListLength() public view returns (uint256) {
        return likeList.length;
    }

    function commentListLength() public view returns (uint256) {
        return commentIDs.length;
    }

    function getDetailedPostInformation()
        public
        view
        returns (
            address[] memory _likeList,
            address[] memory _commentIDs,
            uint256[] memory _commentTimeStamps
        )
    {
        return (likeList, commentIDs, commentTimeStamps);
    }

    event LikePost(address user);
    event PostComment(address user);
}
