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

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function deposit() external payable {
        userBalance[msg.sender] += msg.value;

        emit depositEvent(msg.sender, msg.value);
    }

    // Vulnerable function that doesn't follow CEI pattern
    function vulnerableWithdraw() external {
        require(userBalance[msg.sender] > 0, "Not enough balance");

        (bool success,) = msg.sender.call{value: userBalance[msg.sender]}("");
        require(success, "Failed");

        userBalance[msg.sender] = 0;

        //   emit withdrawEvent(msg.sender, currentBalance);
    }

    function defendedWithdraw() external {
        require(userBalance[msg.sender] > 0, "Not enough balance");

        uint256 currentBalance = userBalance[msg.sender];

        userBalance[msg.sender] = 0;

        (bool success,) = msg.sender.call{value: currentBalance}("");
        require(success, "Failed");
        //   emit withdrawEvent(msg.sender, currentBalance);
    }

    receive() external payable {
        userBalance[msg.sender] += msg.value;

        emit depositEvent(msg.sender, msg.value);
    }
}
