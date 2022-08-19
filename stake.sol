// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Staking {
    address public owner;

    struct Position {
        uint positionId;
        address walletAddress;
        uint createdDate;
        uint unlockDate;
        uint percentInterest;
        uint weiStaked;
        uint weiInterest;
        bool open;
    }

    Position position;
    uint public currentPositionId;
    mapping(uint => Position) public positions;
    mapping(address => uint[]) public positionIdsByAddress;
    mapping(uint => uint) public tiers; 
    uint [] public lockPeriods;

    constructor() payable {
        owner = msg.sender;
        currentPositionId = 0;
     //   tiers[30] = 700;
        tiers[90] = 15;
        tiers[270] = 20;

       // lockPeriods.push(30);
        lockPeriods.push(90);
        lockPeriods.push(270);

    }
   
    function stakeEther(uint numSeconds) external payable {
        require(tiers[numSeconds] > 0, "Mapping not found");

        positions[currentPositionId] = Position(
            currentPositionId,
            msg.sender,
            block.timestamp,
            block.timestamp +(numSeconds * 1 seconds),
            tiers[numSeconds], 
            msg.value,
            calculateInterest(tiers[numSeconds],numSeconds, msg.value),
            true
        );

        positionIdsByAddress[msg.sender].push(currentPositionId);
        currentPositionId +=1;
    }

    function calculateInterest(uint basisPoints,uint numSeconds, uint weiAmount) private pure returns(uint) {
        return basisPoints  * weiAmount / 100; // 700 /10000 => 0.07
    }

    function modifyLockPeriods(uint numSeconds, uint basisPoints) external{
        require(owner == msg.sender, "only owner may modify staking periods" );

        tiers[numSeconds] = basisPoints;
        lockPeriods.push(numSeconds);
    }

    function getLockPeriods() external view returns(uint[] memory) {
        return lockPeriods;
    }

    function getInterestRate(uint numSeconds) external view returns(uint) {
        return tiers[numSeconds];
    }

    function getPositionById(uint positionId) external view returns(Position memory) {
        return positions[positionId];
    }

    function getPositionIdsForAddress(address walletAddress) external view returns(uint[] memory){
        return positionIdsByAddress[walletAddress];
    }

    function changeUnlockDate(uint positionId,  uint newUnlockDate) external {
        require(owner == msg.sender, "Only owner may modify staking periods");

        positions[positionId].unlockDate = newUnlockDate;
    }

    function closePosition(uint positionId) external {
        require(positions[positionId].walletAddress == msg.sender, "Only position creator may modifiy position");
        require(positions[positionId].open == true, "Position is closed");

        positions[positionId].open = false;

        if(block.timestamp > positions[positionId].unlockDate){
            uint amount = positions[positionId].weiStaked + positions[positionId].weiInterest;
            payable(msg.sender).call{value: amount}('');
        }else {
           revert(" staked time period not completed ");
          //payable(msg.sender).call{value: positions[positionId].weiStaked}("");
        }


    }
}

//contracr address - 0xBeb4f0083c44b703A2649452DfD4a2954Ae73815