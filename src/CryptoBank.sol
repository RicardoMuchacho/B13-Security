// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.24;

contract CryptoBank {
   address owner;
   uint256 private bankBalance;
   mapping(address user => uint256 balance) public userBalance;
   mapping(address user => uint256 loan) private userLoan;
   constructor() payable {
      bankBalance = msg.value;
      owner = msg.sender;
   }

   event depositEvent(address account, uint256 amount);
   event withdrawEvent(address account, uint256 amount);
   function deposit() external payable {
      userBalance[msg.sender] += msg.value;

      emit depositEvent(msg.sender, msg.value);
   }
   
   // Vulnerable function that doesn't follow CEI pattern
    function vulnerableWithdraw(uint256 amount) external {
      require(userBalance[msg.sender] >= amount, "Not enough balance");
      
      (bool success, )  = msg.sender.call{value: amount}("");
      require(success, "Failed");

      userBalance[msg.sender] -= amount;

      emit withdrawEvent(msg.sender, amount);
   } 

   function withdraw(uint256 amount) external {
      //checks
      require(userBalance[msg.sender] >= amount, "Not enough balance");

      //effects
      userBalance[msg.sender] -= amount;

      //interactions with state
      (bool success, )  = msg.sender.call{value: amount}("");
      require(success, "Failed");

      emit withdrawEvent(msg.sender, amount);
   } 

    receive() external payable {
      userBalance[msg.sender] += msg.value;

      emit depositEvent(msg.sender, msg.value);
   }
}