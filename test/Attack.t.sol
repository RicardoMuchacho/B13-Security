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
        vm.deal(attackerAdr, 5 ether);
        vm.deal(address(attacker), 5 ether);
        vm.startPrank(attackerAdr);
        
        vm.expectRevert();
        attacker.attack(2 ether);

        console.log(attackerAdr.balance);
        console.log(address(attacker).balance);
        console.log(address(bank).balance);
        
        attacker.getStolenFunds();
        // assertLe(address(bank).balance, 1.99 ether);
        // assertGt(address(attacker).balance, 1 ether);

        vm.stopPrank();
    }
}