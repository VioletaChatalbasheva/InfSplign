#!/bin/sh



#SBATCH --job-name=visor_test_dist
#SBATCH --partition=ptix-h100
#SBATCH --account=mv
#SBATCH --time=4:00:00
#SBATCH --ntasks=32
#SBATCH --output=job_%j.out
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=12
#SBATCH --gres=gpu:h100:8
#SBATCH --mail-type=END,FAIL         
#SBATCH --mail-user=sieger.falkena@shell.com  

# ------------------------------------------------------------------------------
# Printing some information
# -----------------------------------------------------------------------------

/usr/bin/scontrol show job -d "$SLURM_JOB_ID"

# ------------------------------------------------------------------------------
# Setting up the environment
# ------------------------------------------------------------------------------

echo "----------------- Environment ------------------"
# module load MPICH
module load OpenMPI/4.1.6-intel-compilers-2021.2.0-CUDA-12.2.2 # Load OpenMPI module

source /glb/home/nlasqh/.bashrc 
conda activate splign
cd /glb/bng/pt.simpl/proj.nobackup/vhpc/nlasqh/Thesis-Splign

# ------------------------------------------------------------------------------
# And finally running the code
# ------------------------------------------------------------------------------

echo "--------------- Running the code ---------------"

echo -n "This run started on: "
date

python -c "import torch; print(torch.cuda.device_count())"
nvidia-smi


mpirun --map-by ppr:$SLURM_NTASKS_PER_NODE:node --np $SLURM_NTASKS --output-filename outputs python pipeline_batch.py --do_multiprocessing True --benchmark visor --json_filename visor_3160 --model sdxl --two_objects True --loss_type relu --loss_num 1 --margin 0.1 --alpha 1.0 --img_id relu_mean --centroid_type mean --batch_size 3 --job_id $SLURM_JOB_ID

echo -n "This run completed on: "
date
