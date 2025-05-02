// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.24;

import "../src/Attacker.sol";
import "../src/CryptoBank.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract AttackTest is Test {
  
    address public bankOwner = vm.addr(1);
    address public attackerAdr = vm.addr(2);
    CryptoBank public bank;
    Attacker public attacker;
    uint256 initalBankBalance = 10 ether;

    function setUp() public {
        vm.deal(bankOwner, 11 ether);
        vm.startPrank(bankOwner);

        bank = new CryptoBank{value: initalBankBalance}();

        vm.stopPrank();
      
        vm.startPrank(attackerAdr);
        attacker = new Attacker(payable(address(bank)));
        vm.stopPrank();
    }

    function test_contractsDeployed() public view {
        assert(address(attacker) != address(0));
        assert(address(bank) != address(0));
        assertEq(address(bank).balance, initalBankBalance);
    }

    function test_depositCorrectly() public {
        uint256 depositAmount = 1 ether;
        vm.deal(attackerAdr, depositAmount);
        vm.startPrank(attackerAdr);
        
        bank.deposit{value: depositAmount}();

        assertEq(address(bank).balance, initalBankBalance + depositAmount);

        vm.stopPrank();
    }

        function test_withdrawCorrectly() public {
        uint256 depositAmount = 1 ether;
        vm.deal(attackerAdr,depositAmount);
        vm.startPrank(attackerAdr);
        
        bank.deposit{value: depositAmount}();
        bank.withdraw(1 ether);

        assertEq(address(bank).balance, initalBankBalance);
        assertEq(attackerAdr.balance, depositAmount);

        vm.stopPrank();
    }

    function test_attackVulnerableWithdraw() public {
        uint256 ethForAttack = 2 ether;
        vm.deal(attackerAdr, ethForAttack);
        vm.deal(address(attacker), ethForAttack);
        vm.startPrank(attackerAdr);

        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = attackerAdr.balance;
        
        attacker.attack(ethForAttack);
        attacker.getStolenFunds();

        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = attackerAdr.balance;
        

        assertEq(bankBalanceAfter, 0);
        assertEq(attackerBalanceAfter, bankBalanceBefore + attackerBalanceBefore + ethForAttack);

        vm.stopPrank();
    }
}