# Vexanium Smart Contracts

Smart contracts for the Vexanium blockchain, built on the Antelope protocol. This repo covers the system contract (vexcore), token contract (vex.token), and multisig contract (vex.msig), along with supporting contracts used at chain genesis.

## Contracts

**vexcore** ([source](contracts/vexcore/)) — The main system contract. Handles block producer registration, staking, REX, RAM market, voting, inflation, and resource management. Deployed to the `vexcore` account.

**vex.token** ([source](contracts/eosio.token/)) — Fungible token contract for VEX and other tokens on the chain. Deployed to the `vex.token` account.

**vex.msig** ([source](contracts/eosio.msig/)) — Multisig contract for proposing and executing transactions that require approval from multiple accounts. Deployed to the `vex.msig` account.

**eosio.boot** — Minimal bootstrap contract used to activate protocol features during chain genesis.

**eosio.bios** — Simplified alternative to vexcore, suitable for testnets or centralized chains.

**eosio.wrap** — Executes transactions that bypass normal authorization requirements. Restricted to trusted chain operators.

## Changes from Upstream

This repo is a fork of [AntelopeIO/reference-contracts](https://github.com/AntelopeIO/reference-contracts) with the following changes:

- All `eosio.*` account names replaced with Vexanium equivalents: `vexcore`, `vex.token`, `vex.msig`, `vex.fees`, `vex.reserv`, etc.
- `migrate()` action added to vexcore for one-time transition of the `global4` table format
- `vexlimits` singleton added to store daily REX withdraw and undelegate limits
- `regfinkey` bug fix: `PUB_BLS` prefix validation added directly in the action, without relying on `to_binary()` which is disabled while `BLS_PRIMITIVES2` is not yet active on Vexanium
- BLS finality (`set_finalizers`) disabled until `BLS_PRIMITIVES2` protocol feature is activated
- Build flags: `SYSTEM_BLOCKCHAIN_PARAMETERS=OFF`, `SYSTEM_CONFIGURABLE_WASM_LIMITS=OFF`

## Building

**Requirements**

- [CDT](https://github.com/AntelopeIO/cdt) 4.1.1, installed at `/usr/opt/cdt/4.1.1/`
- [Spring](https://github.com/AntelopeIO/spring) v1.2.2 (only needed for tests)

**Build contracts**

```bash
mkdir -p build && cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=OFF \
  -DSYSTEM_BLOCKCHAIN_PARAMETERS=OFF \
  -DSYSTEM_CONFIGURABLE_WASM_LIMITS=OFF
make -j$(nproc)
```

Output: `build/contracts/vexcore/` and `build/contracts/eosio.token/`

**Verify hashes**

```bash
sha256sum build/contracts/vexcore/vexcore.wasm
# ae739d581148e323c261b7a186e9ec94ed7945755353af1d8d1547e243fce6b4

sha256sum build/contracts/vexcore/vexcore.abi
# fd3bebbdcb6567ad78df56b2fa2c08b4a6630f8b479d42956910a33844472e48
```

**Build with tests**

```bash
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=ON \
  -DSYSTEM_BLOCKCHAIN_PARAMETERS=OFF \
  -DSYSTEM_CONFIGURABLE_WASM_LIMITS=OFF \
  -Dspring_DIR="${SPRING_BUILD_PATH}/lib/cmake/spring"
make -j$(nproc)
cd tests && ctest -j$(nproc)
```

## Deploying to Mainnet

All changes on Vexanium mainnet require a multisig proposal approved by at least 15 of the 21 active Block Producers. There is no direct access to the `vexcore` account.

## License

[MIT](LICENSE)
