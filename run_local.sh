#!/bin/bash

# Configuration
PROJECT_DIR="$(pwd)"
VENV_DIR="$PROJECT_DIR/venv"
CONFIG_FILE="./results/pretrain/pretrain.yaml"

# Environment Variables for Distributed Training (Local 1-process mode)
export MASTER_ADDR="127.0.0.1"
export MASTER_PORT="29505"
export RANK=0
export WORLD_SIZE=1

# Hardware Optimizations for Mac
export OMP_NUM_THREADS=8
export NUMEXPR_MAX_THREADS=8

# Activate virtual environment
if [ -d "$VENV_DIR" ]; then
    echo "Activating virtual environment..."
    source "$VENV_DIR/bin/activate"
else
    echo "Error: Virtual environment not found at $VENV_DIR"
    exit 1
fi

# Ensure output directory exists
mkdir -p results/pretrain

echo "Starting local pretraining on M4 Pro (MPS)..."
echo "Batch Size: 15 | Max Epochs: 50"

# Using torchrun for a clean single-node initialization
python3 -m torch.distributed.run \
    --nproc_per_node=1 \
    --master_addr=$MASTER_ADDR \
    --master_port=$MASTER_PORT \
    main.py --cfg_file "$CONFIG_FILE"
