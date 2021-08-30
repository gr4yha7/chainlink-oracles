pragma solidity 0.6.6;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract SimpleLottery is VRFConsumerBase {
  bytes32 internal keyHash;
  uint256 internal fee;
  
  uint256 public randomResult;
  uint256 public totalFunds;
  address payable[] public lotteryPlayers;
  address payable public lotteryWinner;
  constructor() 
    VRFConsumerBase(
      0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
      0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
    ) public
  {
    keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
  }
  
  /** 
    * Requests randomness 
    */
  function getRandomNumber() public returns (bytes32 requestId) {
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    return requestRandomness(keyHash, fee);
  }

  /**
    * Callback function used by VRF Coordinator
    */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
     // randomness.mod(100).add(1) - request a random number between 1 and 100
    randomResult = randomness;
  }
  
  function joinLottery() public payable {
    require(msg.value != 0, "cannot send zero ether");
    totalFunds += msg.value;
    lotteryPlayers.push(msg.sender);
  }
  
  function pickWinner() public {
    if (randomResult > 0) {
      uint256 index = randomResult % lotteryPlayers.length;
      lotteryWinner = lotteryPlayers[index];
      lotteryWinner.transfer(totalFunds);
    } else revert("Random number not available yet");
  }

}