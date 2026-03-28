#!/bin/bash
#SBATCH --account=def-downd
#SBATCH --gres=gpu:1              # Request 1 GPU
#SBATCH --cpus-per-task=4         # Request 4 CPUs
#SBATCH --mem=32G                 # Request 32GB RAM
#SBATCH --time=0-04:00:00         # 4 hours max
#SBATCH --output=%j.out           # Standard output
#SBATCH --error=%j.err            # Standard error
#SBATCH --job-name=coachme_pretrain_narval

# Load modules
module load gcc arrow
module load python/3.10
module load scipy-stack

# Use a persistent virtualenv in the project directory
# This allows us to install packages like 'dotenv' and 'bert-score' on the login node (with internet)
VENV_PATH="/home/mmdmir/projects/def-downd/mmdmir/coachme_venv"
source $VENV_PATH/bin/activate

# Optional: Verify main packages are present (offline)
pip install --no-index torch torchvision torchaudio pytorch_lightning transformers  --quiet

# Run pre-training (single GPU, gloo backend for compatibility)
python -m torch.distributed.run \
    --nproc_per_node=1 \
    --master_port=29050 \
    main.py --cfg_file ./results/pretrain/pretrain.yaml
