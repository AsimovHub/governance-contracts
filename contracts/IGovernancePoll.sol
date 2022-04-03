// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IGovernancePoll {

    // DESCRIPTION OF POLL
    function getPollDescription() external view returns (string memory);

    // COUNT OF OPTIONS
    function getOptionCount() external view returns (uint256);

    // NAME OF OPTION
    function getOptionName(uint256 option_) external view returns (string memory);

    // TOTAL VOTES OF OPTION
    function getCurrentVotesOfOption(uint256 option_) external view returns (uint256);

    // TOTAL VOTES
    function getTotalVotes() external view returns (uint256);

    // TOTAL VOTERS
    function getTotalVoters() external view returns (uint256);

    // GET VOTED OPTION OF VOTER
    function getSelectedVote() external view returns (uint256);
    function getVoteForVoter(address voter_) external view returns (uint256);

    // GET VOTED POWER OF VOTER
    function getVotedPowerForVoter(address voter_) external view returns (uint256);

    // VOTE ON OPTION
    function voteOnGovernance(uint256 option_) external;

    // GET WINNING OPTION
    function getWinnerOption() external view returns (uint256);

    function startPoll() external;
    function pausePoll() external;
    function closePoll() external;

    function isPaused() external view returns (bool);
    function isClosed() external view returns (bool);
    function hasVoted(address sender_) external view returns (bool);

}
