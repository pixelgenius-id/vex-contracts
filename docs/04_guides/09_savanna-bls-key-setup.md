# BLS Finalizer Key Setup Guide for Savanna Consensus

This guide is for Vexanium Block Producers (BPs) preparing for **Savanna consensus** activation. Savanna upgrades the consensus mechanism from dPoS to BFT (Byzantine Fault Tolerant) using BLS cryptography, providing deterministic finality within 1–2 seconds.

## Prerequisites

Before starting, ensure:

- Nodeos **Spring v1.2.2** or newer is running
- `spring-util` binary is installed (see [Installing spring-util](#installing-spring-util))
- Your BP account is registered as an active producer on Vexanium mainnet
- `cleos` is configured to point at a Vexanium mainnet API node

## Savanna Activation Overview

```
[Governance]  Proposal to activate BLS_PRIMITIVES2  →  15/21 BPs approve
[All BPs]     Generate BLS key + register on-chain (regfinkey)
[Governance]  Proposal to activate SAVANNA           →  15/21 BPs approve
[Governance]  Deploy vexcore upgrade (enables set_finalizers)
[vexcore]     switchtosvnn  →  Savanna is live
```

---

## Step 1: Install spring-util

`spring-util` is the Spring CLI tool for BLS key operations.

### Option A: Build from source (recommended)

```bash
git clone https://github.com/AntelopeIO/spring.git
cd spring
git checkout v1.2.2
git submodule update --init --recursive

mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc) spring-util

# Binary location:
./programs/spring-util/spring-util --version
```

### Option B: Download release binary

Check https://github.com/AntelopeIO/spring/releases for a Spring v1.2.2 pre-built package.

Verify the installation:
```bash
spring-util --version
```

---

## Step 2: Generate a BLS Keypair

Run the following on your BP server:

```bash
spring-util bls create key --to-console
```

Example output:
```
Private key: PVT_BLS_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Public key:  PUB_BLS_YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
Proof of Possession: SIG_BLS_ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
```

> **IMPORTANT — Keep the private key secure!**
> The private key (`PVT_BLS_...`) must be stored safely and must never be shared. Losing it means your node cannot participate in Savanna finality voting.

To save to a file instead:
```bash
spring-util bls create key -f /etc/nodeos/bls_finalizer_key.txt
chmod 600 /etc/nodeos/bls_finalizer_key.txt
```

File format:
```
Private key: PVT_BLS_xxx...
Public key: PUB_BLS_yyy...
Proof of Possession: SIG_BLS_zzz...
```

---

## Step 3: Add the BLS Key to nodeos Configuration

Edit your `config.ini` and add a `signature-provider` entry for the BLS key:

```ini
# config.ini

# Existing block-signing key (do not remove):
signature-provider = VEX6xxxYourExistingPublicKey=KEY:5KxxxYourExistingPrivateKey

# BLS finalizer key (add this):
signature-provider = PUB_BLS_yyy...=KEY:PVT_BLS_xxx...
```

Replace `PUB_BLS_yyy...` and `PVT_BLS_xxx...` with the values from Step 2.

Then **restart nodeos**:

```bash
# systemd
sudo systemctl restart nodeos

# or manually
pkill nodeos
nodeos --config-dir /etc/nodeos --data-dir /data/nodeos [your other flags]
```

Verify nodeos loaded the BLS key:
```bash
journalctl -u nodeos -n 50 | grep -i "bls\|finaliz"
```

---

## Step 4: Register the BLS Key On-Chain (`regfinkey`)

Once the `BLS_PRIMITIVES2` protocol feature is activated on mainnet via governance, run:

```bash
cleos -u https://api.vexanium.com push action vexcore regfinkey \
  '{
    "finalizer_name": "YOUR_BP_ACCOUNT",
    "finalizer_key":  "PUB_BLS_yyy...",
    "proof_of_possession": "SIG_BLS_zzz..."
  }' \
  -p YOUR_BP_ACCOUNT@active
```

- `finalizer_name` — your BP account name (e.g. `greengemclan`)
- `finalizer_key` — BLS public key from Step 2 (`PUB_BLS_...`)
- `proof_of_possession` — proof of possession from Step 2 (`SIG_BLS_...`)

Verify the registration:
```bash
cleos -u https://api.vexanium.com get table vexcore vexcore finkeys \
  --index 2 --key-type name --lower YOUR_BP_ACCOUNT --upper YOUR_BP_ACCOUNT
```

---

## Step 5: Activate the BLS Key (`actfinkey`) — Optional

If you registered more than one key, activate the desired one:

```bash
cleos -u https://api.vexanium.com push action vexcore actfinkey \
  '{
    "finalizer_name": "YOUR_BP_ACCOUNT",
    "finalizer_key":  "PUB_BLS_yyy..."
  }' \
  -p YOUR_BP_ACCOUNT@active
```

> The first key registered is automatically set as active. `actfinkey` is only needed when switching between multiple registered keys.

---

## Verifying Your Status

```bash
# Check all registered finalizers
cleos -u https://api.vexanium.com get table vexcore vexcore finalizers

# Check your BP's registered keys
cleos -u https://api.vexanium.com get table vexcore vexcore finkeys \
  --index 2 --key-type name --lower YOUR_BP_ACCOUNT --upper YOUR_BP_ACCOUNT
```

Expected output:
```json
{
  "finalizer_name": "YOUR_BP_ACCOUNT",
  "active_key_id": 0,
  "active_key_binary": "",
  "finalizer_key_count": 1
}
```

---

## Key Rotation

If you need to replace your BLS key (e.g. server migration or suspected key compromise):

1. Generate a new BLS keypair (repeat Step 2)
2. Update `config.ini` with the new key and restart nodeos
3. Register the new key on-chain:
   ```bash
   cleos push action vexcore regfinkey \
     '{"finalizer_name":"YOUR_BP","finalizer_key":"PUB_BLS_NEW...","proof_of_possession":"SIG_BLS_NEW..."}' \
     -p YOUR_BP@active
   ```
4. Activate the new key:
   ```bash
   cleos push action vexcore actfinkey \
     '{"finalizer_name":"YOUR_BP","finalizer_key":"PUB_BLS_NEW..."}' \
     -p YOUR_BP@active
   ```
5. Delete the old key (optional):
   ```bash
   cleos push action vexcore delfinkey \
     '{"finalizer_name":"YOUR_BP","finalizer_key":"PUB_BLS_OLD..."}' \
     -p YOUR_BP@active
   ```

> **Note:** An active key cannot be deleted while other keys are registered. Activate the new key first, then delete the old one.

---

## Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `finalizer key was already registered` | Key was already submitted | Generate a new keypair or check the `finkeys` table |
| `finalizer X is not a registered producer` | Account is not an active BP | Register as a producer first via `regproducer` |
| `proof_of_possession signature does not start with SIG_BLS` | Wrong PoP format | Copy the exact output from `spring-util bls create key` |
| `BLS_PRIMITIVES2 not yet activated` | Protocol feature not active yet | Wait for the governance proposal to pass |
| nodeos does not load BLS key | Missing `signature-provider` in config | Add the entry and restart nodeos |

---

## FAQ

**Q: Is the BLS key the same as my block-signing key (`VEX6...`)?**
No. Your block-signing key (format `VEX6...`) is used to sign produced blocks. The BLS finalizer key (format `PUB_BLS_...`) is used exclusively for Savanna finality voting. Both must be present in `config.ini`.

**Q: Does Savanna activate immediately after I call `regfinkey`?**
No. `regfinkey` only registers your key on-chain. Savanna goes live only after:
1. Protocol features `BLS_PRIMITIVES2` and `SAVANNA` are activated via governance
2. At least the top 21 BPs have called `regfinkey`
3. `switchtosvnn` is called by `vexcore@active`

**Q: What happens if my node does not have a BLS key when Savanna activates?**
Your node can still produce blocks, but it will not participate in Savanna finality voting. This means your node does not contribute to the 2/3+1 threshold required for block finality. All top-21 BPs should be ready before `switchtosvnn` is executed.

**Q: Does the BLS private key need to be stored in keosd?**
No. The BLS private key is configured directly in `config.ini` using the format `KEY:PVT_BLS_...`. keosd is not involved.

**Q: Can I use the same BLS key on multiple nodes?**
Technically yes, but it is strongly discouraged. Each node signing with the same BLS key creates a risk of double-signing, which can harm finality. Use a unique BLS key per node.
