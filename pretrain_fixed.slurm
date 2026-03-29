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
module load gcc arrow
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

# Run pre-training (single GPU, using torchrun)
torchrun \
    --nproc_per_node=1 \
    --master_port=29505 \
    main.py --cfg_file ./results/pretrain/pretrain.yaml
