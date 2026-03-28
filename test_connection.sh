#!/bin/bash

# Configuration
CLUSTER_USER="mag-130"
CLUSTER_HOST="cedar.computecanada.ca"
KEY_PATH="/Users/mohamad/Desktop/git/course/cas732/alliance_key"

echo "Testing connection to ${CLUSTER_HOST} using SSH key..."
echo "Note: If it asks for a password, just press Ctrl+C. That means the key hasn't propagated yet."

ssh -i ${KEY_PATH} -o BatchMode=yes -o ConnectTimeout=5 ${CLUSTER_USER}@${CLUSTER_HOST} "echo 'Connection SUCCESSFUL!'"

if [ $? -eq 0 ]; then
    echo "Wait for key propagation..."
else
    echo "Key not yet recognized by the server. Please wait another 15-20 minutes."
fi
