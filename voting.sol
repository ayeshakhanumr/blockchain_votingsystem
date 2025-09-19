// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Voting {
    struct Candidate { uint id; string name; string party; uint voteCount; }
    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public voters;

    uint public countCandidates;
    uint256 public votingStart;
    uint256 public votingEnd;

    address public owner;

    constructor() { owner = msg.sender; }

    modifier onlyOwner() { require(msg.sender == owner, "Only owner can call this"); _; }
    modifier whenOpen() {
        require(block.timestamp >= votingStart && block.timestamp < votingEnd, "Voting is not open");
        _;
    }

    function addCandidate(string memory name, string memory party)
        public onlyOwner returns (uint)
    {
        countCandidates++;
        candidates[countCandidates] = Candidate(countCandidates, name, party, 0);
        return countCandidates;
    }

    function vote(uint candidateID) public whenOpen {
        require(candidateID > 0 && candidateID <= countCandidates, "Invalid candidate");
        require(!voters[msg.sender], "Already voted");
        voters[msg.sender] = true;
        candidates[candidateID].voteCount++;
    }

    function checkVote() public view returns (bool) { return voters[msg.sender]; }
    function getCountCandidates() public view returns (uint) { return countCandidates; }
    function getCandidate(uint candidateID) public view returns (uint, string memory, string memory, uint) {
        Candidate storage c = candidates[candidateID];
        return (c.id, c.name, c.party, c.voteCount);
    }

    function setDates(uint256 _startDate, uint256 _endDate) public onlyOwner {
        require(votingStart == 0 && votingEnd == 0, "Dates already set");
        require(_startDate > block.timestamp, "Start must be in future");
        require(_endDate > _startDate, "End must be after start");
        votingStart = _startDate;
        votingEnd   = _endDate;
    }

    function getDates() public view returns (uint256, uint256) { return (votingStart, votingEnd); }
}
