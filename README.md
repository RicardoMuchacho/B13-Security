# 🛡️ Reentrancy Attack Simulation

This project demonstrates a classic **Reentrancy Attack** on an insecure Ethereum smart contract and how such vulnerabilities can be exploited if **the Checks-Effects-Interactions (CEI) pattern** is not followed. The example includes a vulnerable `CryptoBank` contract, an `Attacker` contract that exploits it, and comprehensive tests using **Foundry**.

## 🧠 Introduction to Reentrancy and CEI

Reentrancy occurs when a contract calls an external contract before it updates its internal state. If the external contract calls back into the vulnerable contract before the first call finishes, it can execute code again — often draining funds.

To prevent this, developers use the **CEI pattern**, which involves:

1. **Check**: Validate inputs and conditions.
2. **Effects**: Update contract state.
3. **Interactions**: Interact with external contracts (e.g., send Ether).

Failing to apply CEI can allow attackers to repeatedly exploit vulnerable functions like withdrawals before the balance is updated.

---

## ✨ Key Features

* 💣 Demonstrates a **reentrancy exploit** using a crafted attacker contract.
* 🧪 **Tested with Foundry**, with detailed branch and coverage analysis.
* 🔍 Covers multiple execution branches, including edge case handling.
* 🔒 Educates on safe contract design using **CEI** and best practices.
* 🧵 Includes a fallback-based attack loop for recursive calls.

---

## 🔧 Project Structure

| Contract           | Description                                                              |
| ------------------ | ------------------------------------------------------------------------ |
| `CryptoBank.sol`   | A vulnerable ETH bank contract allowing deposits and unsafe withdrawals. |
| `Attacker.sol`     | Attacker contract that exploits `CryptoBank` through recursive fallback. |
| `AttackTest.t.sol` | Foundry test suite validating successful and failed attack paths.        |

---

## 🧩 Contract Overview

### `Attacker.sol`

| Function           | Description                                                          |
| ------------------ | -------------------------------------------------------------------- |
| `attack()`         | Deposits and triggers the reentrancy vulnerability in `CryptoBank`.  |
| `getStolenFunds()` | Withdraws stolen funds to the attacker address.                      |
| `receive()`        | Reenters `CryptoBank.vulnerableWithdraw()` if balance is sufficient. |

---

## 🛠 How to Use

### Prerequisites

* [Foundry](https://book.getfoundry.sh/) installed (`forge`, `cast`, etc.)

### Run Tests

```bash
forge test
```

### Run Coverage

```bash
forge coverage
```

---

## 🚨 Security Takeaways

* Always **update state before** interacting with external addresses.
* Use **reentrancy guards** (`nonReentrant`) for critical functions.
* Treat any external contract call (including sending ETH) as potentially untrusted.
* Write **unit tests that explore all logic branches**, including failure scenarios.