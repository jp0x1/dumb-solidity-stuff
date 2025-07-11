// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
    }

    event ProposalCreated(uint id);
    event VoteCast(uint id, address voter);
    Proposal[] public proposals;
    bool voted;
    uint256 voteIdx = 0;
    uint256 propId;
    bool executed;

    constructor(address[] memory addresses) {
        for (uint i=0; i<addresses.length;i++){
            proposals.push(Proposal(addresses[i], "", 0, 0));
        }
    }

    function verify(address addr) public returns (bool) {
        for (uint i=0; i<proposals.length;i++){
            if (proposals[i].target == addr) {
                return true;
            }
        }
        return false;
    }

    function newProposal(address target, bytes memory data) external {
        if (verify(msg.sender)) {
            proposals.push(Proposal(target, data, 0, 0));
            emit ProposalCreated(propId);
            propId++;
        }
    }

    function castVote(uint proposalId, bool vote) external {
        
        if (verify(msg.sender)) {
            if (voted) {
                if (vote) {
                    proposals[proposalId].yesCount += 1;
                    emit VoteCast(proposalId, msg.sender);
                    voteIdx++;
                } else {   
                    proposals[proposalId].noCount += 1;
                    emit VoteCast(proposalId, msg.sender);
                    voteIdx++;
                }
            } else {
                if (vote) {
                    proposals[proposalId].yesCount += 1;
                    emit VoteCast(proposalId, msg.sender);
                    voteIdx++;
                } else {
                    proposals[proposalId].noCount += 1;
                    emit VoteCast(proposalId, msg.sender);
                    voteIdx++;
                }
                voted = true;
            }
        
        } else {
            revert();
        }
        
        if (voteIdx >= 10) {
            if (executed == false) {
                Proposal storage proposal = proposals[proposalId];

                // Execute the proposal by calling the target with the data
                (bool success, ) = proposal.target.call(proposal.data);
                require(success, "Proposal execution failed");
                executed = true;
            }
        }
    }

}