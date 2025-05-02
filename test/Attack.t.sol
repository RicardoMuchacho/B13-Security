// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.24;

import "../src/Attacker.sol";
import "../src/CryptoBank.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract RejectEther {
    fallback() external payable {
        revert("Rejecting ETH");
    }
}

contract AttackTest is Test {
    address public bankOwner = vm.addr(1);
    address public attackerAddr = vm.addr(2);
    CryptoBank public bank;
    Attacker public attacker;
    uint256 initalBankBalance = 10 ether;

    function setUp() public {
        vm.deal(bankOwner, 11 ether);
        vm.startPrank(bankOwner);

        bank = new CryptoBank{value: initalBankBalance}();

        vm.stopPrank();

        vm.startPrank(attackerAddr);
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
        vm.deal(attackerAddr, depositAmount);
        vm.startPrank(attackerAddr);

        bank.deposit{value: depositAmount}();

        assertEq(address(bank).balance, initalBankBalance + depositAmount);

        vm.stopPrank();
    }

    function test_withdrawCorrectly() public {
        uint256 depositAmount = 1 ether;
        vm.deal(attackerAddr, depositAmount);
        vm.startPrank(attackerAddr);

        bank.deposit{value: depositAmount}();
        bank.defendedWithdraw();

        assertEq(address(bank).balance, initalBankBalance);
        assertEq(attackerAddr.balance, depositAmount);

        vm.stopPrank();
    }

    function test_attackVulnerableWithdraw() public {
        uint256 ethForAttack = 2 ether;
        vm.deal(attackerAddr, ethForAttack);
        vm.deal(address(attacker), ethForAttack);
        vm.startPrank(attackerAddr);

        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = attackerAddr.balance;

        attacker.attack(ethForAttack);
        attacker.getStolenFunds();

        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = attackerAddr.balance;

        assertEq(bankBalanceAfter, 0);
        assertEq(attackerBalanceAfter, bankBalanceBefore + attackerBalanceBefore + ethForAttack);

        vm.stopPrank();
    }

    function test_getStolenFundsFailure() public {
        RejectEther rejector = new RejectEther();
        vm.deal(address(attacker), 1 ether);

        vm.prank(address(rejector));
        // Expect revert when trying to forward funds to rejecting contract
        vm.expectRevert("Failed");
        attacker.getStolenFunds();
    }
}
