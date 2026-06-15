#!/bin/bash
# Deploy vexcore via msig proposal
# Run AFTER compile selesai

WASM="/tmp/vexcore_new.wasm"
ABI="/tmp/vexcore_new.abi"
CONTRACT="vexcore"
PROPOSER="lionvexanium"
PROPOSAL_NAME="upgvexcore1"
ENDPOINT="http://127.0.0.1:8888"
MSIG_CONTRACT="vex.msig"

# BP list yang perlu approve (21 BPs, threshold 15)
BPS=(ad24 bitcoinnkri bpforvexasia databisnisid dejave digitalstake elitgloball1
     galaxybpvexa greengemclan honestmining komododragon lionvexanium rajawalivexa
     tukarguling vexanddefibp vexaniumcore vexcharity vexpoolbp123 vyndao vyndaotodefi wind)

echo "=== Verifying build outputs ==="
ls -lh $WASM $ABI

echo ""
echo "=== Verifying ABI actions ==="
python3 -c "
import json
with open('$ABI') as f: a = json.load(f)
actions = sorted([x['name'] for x in a['actions']])
tables  = sorted([x['name'] for x in a['tables']])
print('Actions:', actions)
print('Tables:', tables)
print()
for a_name in ['migrate','setrexlimit','setundlimit']:
    print(f'{a_name}: {\"OK\" if a_name in actions else \"MISSING\"}')"

echo ""
echo "=== Creating msig proposal: $PROPOSAL_NAME ==="

# Build requested permissions JSON (all 21 BPs)
REQUESTED='['
for bp in "${BPS[@]}"; do
    REQUESTED+="{\"actor\":\"$bp\",\"permission\":\"active\"},"
done
REQUESTED="${REQUESTED%,}]"

# Create proposal with setcode + setabi + migrate
cleos -u $ENDPOINT multisig propose $PROPOSAL_NAME \
  "$REQUESTED" \
  '[
    {"actor":"vexcore","permission":"active"}
  ]' \
  $CONTRACT setcode \
  "{\"account\":\"$CONTRACT\",\"vmtype\":0,\"vmversion\":0,\"code\":\"$(xxd -p $WASM | tr -d '\n')\"}" \
  -p ${PROPOSER}@active \
  2>&1

echo ""
echo "=== To also propose setabi, run separately ==="
echo "Note: setcode and setabi need to be in same proposal"
echo ""
echo "=== Share this with BPs to approve: ==="
echo "cleos -u $ENDPOINT multisig approve $PROPOSER $PROPOSAL_NAME '{\"actor\":\"<BPNAME>\",\"permission\":\"active\"}' -p <BPNAME>@active"
echo ""
echo "=== Execute when 15+ approvals: ==="
echo "cleos -u $ENDPOINT multisig exec $PROPOSER $PROPOSAL_NAME -p ${PROPOSER}@active"
