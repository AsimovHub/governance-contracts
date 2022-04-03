// SPDX-License-Identifier: UNLICENSED
// Code written by n-three for Asimov Hub

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IGovernancePoll.sol";

contract GovernancePoll001 is IGovernancePoll, Ownable {

    address constant ISAAC_TOKEN_CONTRACT = 0x86FF8138dcA8904089D3d003d16a5a2d710D36D2;

    string internal _pollDescription;
    string[] internal _options;

    address[] internal _voters;
    mapping(address => uint256) _votes;

    bool internal _running;
    bool internal _finalized;

    mapping(uint256 => uint256) _finalVotes;
    uint256 _finalVoteCount;

    constructor() {
        _pollDescription = "Close the ISAAC sale after Phase V and use remaining tokens for staking or just burn them?";
        _options.push("Close & Staking");
        _options.push("Close & Burning");
        _options.push("Continue Sale");
    }

    // DESCRIPTION OF POLL
    function getPollDescription() external view override returns (string memory) {
        return _pollDescription;
    }

    // COUNT OF OPTIONS
    function getOptionCount() external view override returns (uint256) {
        return _options.length;
    }

    // NAME OF OPTION
    function getOptionName(uint256 option_) external view override returns (string memory) {
        if (option_ == 0) {
            return "None";
        }
        return _options[option_ - 1];
    }

    // TOTAL VOTES OF OPTION
    function getCurrentVotesOfOption(uint256 option_) public view override returns (uint256) {
        require (option_ > 0 && option_ <= _options.length, "Vote option not available");
        if (_finalized) {
            return getFinalVoteCount(option_);
        } else {
            uint256 totalVotes_ = 0;
            for (uint256 i = 0; i < _voters.length; i++) {
                if (getVoteForVoter(_voters[i]) == option_) {
                    totalVotes_ += getVotedPowerForVoter(_voters[i]);
                }
            }
            return totalVotes_;
        }
    }

    // TOTAL VOTES
    function getTotalVotes() external view override returns (uint256) {
        if (_finalized) {
            return _finalVoteCount;
        } else {
            uint256 totalVotes_ = 0;
            for (uint256 i = 0; i < _voters.length; i++) {
                totalVotes_ += getVotedPowerForVoter(_voters[i]);
            }
            return totalVotes_;
        }
    }

    // TOTAL VOTERS
    function getTotalVoters() external view override returns (uint256) {
        return _voters.length;
    }

    // GET VOTED OPTION OF VOTER
    function getSelectedVote() external view override returns (uint256) {
        return getVoteForVoter(msg.sender);
    }

    function getVoteForVoter(address voter_) public view override returns (uint256) {
        return _votes[voter_];
    }

    // GET VOTED POWER OF VOTER
    function getVotedPowerForVoter(address voter_) public view override returns (uint256) {
        if (getVoteForVoter(voter_) > 0) {
            return IERC20(ISAAC_TOKEN_CONTRACT).balanceOf(voter_) / (10 ** 18);
        } else {
            return 0;
        }
    }

    // VOTE ON OPTION
    function voteOnGovernance(uint256 option_) external override {
        require(_running, "Poll has not been enabled");
        require(!_finalized, "Poll has been closed");

        require (option_ > 0, "You cannot unvote");
        require (option_ <= _options.length, "Vote option not available");

        if (_votes[msg.sender] == 0) {
            _voters.push(msg.sender);
        }
        _votes[msg.sender] = option_;
    }

    function startPoll() external override onlyOwner {
        _running = true;
    }

    function pausePoll() external override onlyOwner {
        _running = false;
    }

    function closePoll() external override onlyOwner {
        require(!_finalized, "Poll has been already closed");
        for (uint256 i = 1; i <= _options.length; i++) {
            uint256 c = getCurrentVotesOfOption(i);
            _finalVoteCount += c;
            _finalVotes[i] = c;
        }
        _finalized = true;
    }

    function getFinalVoteCount(uint256 option_) internal view returns (uint256) {
        require(_finalized, "Poll has not been closed yet");
        require (option_ > 0 && option_ <= _options.length, "Vote option not available");
        return _finalVotes[option_];
    }

    function isPaused() external view override returns (bool) {
        return !_running;
    }

    function isClosed() external view override returns (bool) {
        return _finalized;
    }

    function hasVoted(address sender_) external view override returns (bool) {
        return getVoteForVoter(sender_) != 0;
    }

    function getWinnerOption() external view override returns (uint256) {
        require(_finalized, "Poll has not been closed yet");
        uint256 topOption = 0;
        uint256 topOptionCount = 0;
        for (uint256 i = 1; i <= _options.length; i++) {
            uint256 c = getFinalVoteCount(i);
            if (c > topOptionCount) {
                topOption = i;
                topOptionCount = c;
            }
        }
        return topOption;
    }

}
