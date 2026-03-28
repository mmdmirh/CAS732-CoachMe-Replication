#!/bin/bash

# Configuration
CLUSTER_USER="mmdmir"
CLUSTER_HOST="narval.alliancecan.ca"
REMOTE_PATH="/home/${CLUSTER_USER}/projects/def-downd/${CLUSTER_USER}/cas732/Project/MotionExpert"
LOCAL_CODE_PATH="."
LOCAL_DATASET_PATH="./dataset"

echo "========================================"
echo "Connecting to ${CLUSTER_HOST}"
echo "1. Enter your password when prompted."
echo "2. Check your phone IMMEDIATELY for Duo Push and approve it."
echo "   OR type your bypass code when asked for Duo."
echo "========================================"

# Create remote directory (requires MFA)
ssh ${CLUSTER_USER}@${CLUSTER_HOST} "mkdir -p ${REMOTE_PATH}/dataset ${REMOTE_PATH}/results"

if [ $? -ne 0 ]; then
    echo "ERROR: SSH connection failed."
    echo "Make sure you:"
    echo "  1. Completed MFA enrollment at https://ccdb.alliancecan.ca/multi_factor_authentications"
    echo "  2. Activated Narval access at https://ccdb.alliancecan.ca/me/access_systems"
    echo "  3. Approved the Duo Push on your phone"
    exit 1
fi

echo "Connection successful! Starting sync..."

# Sync code
rsync -avz -e ssh \
  --exclude 'venv' \
  --exclude 'HumanML3D_generator' \
  --exclude '__pycache__' \
  --exclude '.git' \
  --exclude '*.tar.bz2' \
  --exclude '*.tar.xz' \
  --exclude '*.zip' \
  ${LOCAL_CODE_PATH}/ ${CLUSTER_USER}@${CLUSTER_HOST}:${REMOTE_PATH}/

# Sync datasets
rsync -avz -e ssh \
  ${LOCAL_DATASET_PATH}/ ${CLUSTER_USER}@${CLUSTER_HOST}:${REMOTE_PATH}/dataset/

echo "Transfer complete!"
