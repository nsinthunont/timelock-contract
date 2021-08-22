// contracts/Timelock.sol
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Timelock is ReentrancyGuard{

  using Counters for Counters.Counter;
  Counters.Counter private _boxIds;

  address payable owner;

  constructor() {
    owner = payable(msg.sender);
  }

  // Timelock safety deposit box
  struct Box {
    uint id;
    address depositor;
    address recipient;
    address token;
    uint amount;
    uint createdAt;
    uint duration;
  }

  mapping(uint => Box) public idToBox;

  event NewDeposit(
    uint id,
    uint createdAt,
    uint duration
  );

  function depositTokens(
    address depositor, 
    address recipient,
    address token,
    uint amount,
    uint duration
    ) external {

      // checks
      require(depositor != address(0x0), 'invalid depositor');
      require(recipient != address(0x0), 'invalid recipient');
      require(token != address(0x0), 'invalid token');
      require(amount > 0, 'amount of tokens needs to be greater than 0');
      require(duration > 0, 'duration needs to be greater than 0');

      // increment box id
      _boxIds.increment();
      uint boxId = _boxIds.current();

      uint createdAt = block.timestamp;

      idToBox[boxId] = Box(
        boxId,
        depositor,
        recipient,
        token,
        amount,
        createdAt,
        duration
      );

      emit NewDeposit(boxId, createdAt, duration);

      IERC20(token).transferFrom(depositor, address(this), amount);

  }

  function withdrawTokens(
    uint boxId,
    address recipient
    ) external nonReentrant{ // prevents reentry attacks draining the contract of tokens

      // check if valid
      require(boxId > 0, 'invalid boxId');
      require(boxId <= _boxIds.current(), 'invalid boxId');
      require(recipient != address(0x0), 'invalid recipient');

      Box storage box = idToBox[boxId];

      // check if the box has been withdrawn
      require(box.recipient != address(0x0), 'box has been withdrawn already');

      // withdrawer must know the recipient address
      require(box.recipient == recipient, 'wrong recipient');

      // can only withdraw after the timelock expires
      require( (box.createdAt + box.duration) < block.timestamp, 'timelock not yet expired');

      IERC20(box.token).transfer(recipient, box.amount);

      delete idToBox[boxId];

  }
}