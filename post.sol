// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

contract Post {
    address public poster;
    address[] public commentIDs;
    uint256[] public commentTimeStamps;
    string public imageCID;
    string public imageName;

    constructor(
        address _poster,
        string memory _imageCID,
        string memory _imageName
    ) {
        poster = _poster;
        imageCID = _imageCID;
        imageName = _imageName;
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

    function commentListLength() public view returns (uint256) {
        return commentIDs.length;
    }

    function getDetailedPostInformation()
        public
        view
        returns (
            address[] memory _commentIDs,
            uint256[] memory _commentTimeStamps
        )
    {
        return (commentIDs, commentTimeStamps);
    }

    event PostComment(address user);
}
