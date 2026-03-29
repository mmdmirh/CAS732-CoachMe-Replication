#!/bin/bash
#SBATCH --account=def-downd
#SBATCH --gres=gpu:1              # Request 1 GPU
#SBATCH --cpus-per-task=4         # Request 4 CPUs
#SBATCH --mem=32G                 # Request 32GB RAM
#SBATCH --time=00:10:00           # 10 minutes for testing
#SBATCH --output=%j.out           # Standard output
#SBATCH --error=%j.err            # Standard error
#SBATCH --job-name=coachme_test

# Load modules
module load gcc arrow/14.0.1
module load python/3.11
module load java/17.0.6
module load scipy-stack

# Use the verified absolute path of the virtualenv
VENV_PATH="/home/mmdmir/projects/def-downd/mmdmir/coachme_venv"
export PYTHONPATH=$PYTHONPATH:$(pwd)

if [ -d "$VENV_PATH" ]; then
    source $VENV_PATH/bin/activate
else
    echo "ERROR: Virtual environment not found at $VENV_PATH"
    exit 1
fi

# Pre-run data verification
python HumanML3D_generator/check_data.py

# Verify Java is available for METEOR metric
echo "Testing Java availability:"
java -version || { echo >&2 "Java not found. METEOR will fail."; exit 1; }

export TORCH_SHOW_CPP_STACKTRACES=1
export NCCL_DEBUG=INFO

# Run pre-training (single GPU, using torchrun)
# Add --error-file to capture the stderr from process 0 reliably
torchrun \
    --nproc_per_node=1 \
    --master_port=29505 \
    main.py --cfg_file ./results/pretrain/pretrain.yaml
