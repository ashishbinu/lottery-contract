//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Lottery {

  address public owner;
  uint public lotteryDeadline;
  bool public winnerDeclared;

  address[] public lotteryBuyers;

  event TicketBuying(address _buyer);
  event WinnerDeclaration(address _winner,uint _prize);

  constructor() {
    owner = msg.sender;
    lotteryDeadline = 1 week;
  }

  modifier deadlineOver() {
    require(block.timestamp > lotteryDeadline, "There is another lottery going on.");
    _;
  }

  modifier winnerNotDeclared() {
    require(!winnerDeclared, "There is another lottery going on.");
    _;
  }

  function _setLotteryDeadline(uint _timePeriod) private deadlineOver {
    lotteryDeadline = block.timestamp + _timePeriod;
    emit LotteryDeadlineDeclaration(lotteryDeadline);
  }

  function buyTicket() public payable {
    require(msg.value == 1 ether,"Not 1 ether");
    lotteryBuyers.push(msg.sender);
    emit TicketBuying(msg.sender);
  }

  function declareWinner() public winnerNotDeclared deadlineOver {
    // find a random winner from the lotteryBuyers[];
    uint randomIndex = uint(keccak256(block.timestamp,block.difficulty) % lotteryBuyers.length); 
    address payable _winner = payable(lotteryBuyers[randomIndex]);
    uint _prize = address(this).balance;
    winnerDeclared = true;
    emit WinnerDeclaration(_winner,_prize);
    // send the pool money to the winner
    (bool sent, bytes memory data) = _winner.call{value: _prize}("");
    require(sent, "Failed to send Ether");
    // reset the lotteryDeadline
    _setLotteryDeadline(1 week);
    // emit winnerDeclaration
  }

}
