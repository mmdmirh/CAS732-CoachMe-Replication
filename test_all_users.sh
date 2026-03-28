#!/bin/bash

# Configuration
CLUSTER_HOST="cedar.computecanada.ca"
KEY_PATH="/Users/mohamad/Desktop/git/course/cas732/alliance_key"
USERNAMES=("mag-130" "mag130" "mmdmir" "mmdmir5")

for CLUSTER_USER in "${USERNAMES[@]}"; do
    echo "---------------------------------------"
    echo "Testing connection with: ${CLUSTER_USER}"
    
    # Try SSH with 5 second timeout and BatchMode (no password)
    ssh -i ${KEY_PATH} -o BatchMode=yes -o ConnectTimeout=5 ${CLUSTER_USER}@${CLUSTER_HOST} "echo 'SUCCESS!'" 2>&1 | grep -E "Permission denied|SUCCESS"
    
    # Check if the error is password request by running without BatchMode briefly
    # (We only do this if BatchMode failed)
done

echo "---------------------------------------"
echo "If any say 'SUCCESS', that is your username!"
echo "If all say 'Permission denied (publickey)', we are still waiting for sync."
echo "If they say 'Permission denied (publickey,keyboard-interactive)', the username is likely wrong."
