# Token Dusting Trap

This Proof-of-Concept demonstrates how to detect **token dusting attacks** using the Drosera Network trap architecture.
In Option A, detection relies on an **off-chain bot** combined with an **on-chain registry**, which allows traps to remain lightweight and compliant with Drosera’s trap interface.

---

## 📌 Concept

* **Dusting Attack**: An attacker sends a small number of tokens (“dust”) to a victim’s wallet. Later, the attacker tracks how the wallet interacts with the tokens to deanonymize the victim or trick them into malicious approvals/swaps.
* **Challenge**: Traps cannot directly read logs/events on-chain.
* **Solution**: Off-chain bots detect dusting patterns, write them into a `DustRegistry.sol`, and the trap (`TokenDustingTrap.sol`) queries this registry to decide whether to respond.

---

## 🛠️ How It Works

1. **Off-chain bot** listens for ERC20 `Transfer` events.
2. When a suspicious transfer is detected (below threshold, from unknown source, etc.), the bot computes a **unique interaction ID**:

   ```
   keccak256(wallet, token, from, amount, blockNumber)
   ```
3. Bot calls `DustRegistry.flag(id)` → saves detection result on-chain.
4. `TokenDustingTrap` queries the registry during `collect()` and returns `shouldRespond = true` if flagged.
5. Drosera network receives the trap signal → forwards to responder.
6. Responder sends an alert with rich context (wallet, token, sender, amount, block).

---

## ✅ Use Cases

### 1. **Suspicious Token Dusting**

* A wallet receives **tiny amounts** of tokens from an unknown address.
* Registry marks this as a dusting attempt.
* Trap reports it → responder issues an **alert notification**.

---

### 2. **Mass Dusting Campaign**

* A bot detects the **same source address** sending small amounts of a token to **hundreds of wallets**.
* Each flagged transfer is recorded in `DustRegistry`.
* Trap picks up these flags → alerts can highlight **pattern-based attacks**.

---

### 3. **Front-Running Fake Token Dust**

* Attacker dusts wallets with **fake tokens** that mimic popular ones.
* When victims later attempt to swap, they are directed to a malicious pair.
* Registry detects unusual token contracts with **no whitelist match**.
* Trap reports → responder can warn: *“Suspicious token contract dusted to wallet”*.

---

### 4. **KYC/Privacy Deanonymization via Dust**

* Dust is used to **track wallet clusters** across interactions.
* Off-chain bot flags transfers that link multiple addresses together.
* Registry stores these as **privacy risk dust events**.
* Trap signals → responder can label wallet as *“Possible dust deanonymization target”*.

---

## 🔗 Components

* **DustRegistry.sol**
  Stores dusting detection flags submitted by off-chain bots.

* **TokenDustingTrap.sol**
  Implements Drosera’s `ITrap` interface. Reads flags from `DustRegistry`.

* **Off-chain Bot**
  Detects ERC20 dusting patterns and updates the registry.

* **Responder**
  Receives trap alerts and issues notifications.

---

## ⚡ Benefits of Registry-Driven Approach

* Lightweight on-chain trap (only `view` calls).
* Offloads heavy detection logic to off-chain bots.
* Supports flexible detection rules without redeploying traps.
* Provides rich context (who, what, when) via responder alerts.
