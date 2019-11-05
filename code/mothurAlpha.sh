#! /bin/bash
# mothurAlpha.sh
# William L. Close

##################
# Set Script Env #
##################

# Set the variables to be used in this script
export SHARED=${1:?ERROR: Need to define SHARED.} # Shared file
export COUNT=${2:?ERROR: Need to define COUNT.} # Count file generated from shared file
export SUBTHRESH=${3:?ERROR: Need to define SUBTHRESH.} # Setting threshold for minimum number of reads to subsample
export ALPHA=${4:?ERROR: Need to define ALPHA.} # Names of mothur beta metrics joined by hyphens

# Other variables
export OUTDIR=data/process/



###############################
# Calculate Diversity Metrics #
###############################

# Setting variables to determine number of reads for subsampling
echo PROGRESS: Setting subsampling parameters.

# Pulling smallest number of reads greater than or equal to $SUBTHRESH for use in subsampling 
READCOUNT=$(awk -v SUBTHRESH="${SUBTHRESH}" '$2 >= SUBTHRESH { print $2}' "${COUNT}" | sort -n | head -n 1)

# Run diversity analysis on new aligned data set
echo PROGRESS: Calculating alpha diversity and subsampling to "${READCOUNT}" reads.

# Calculating alpha and beta diversity
# If a sample doesn't have enough reads, it'll be eliminated from the analysis
mothur "#summary.single(shared="${SHARED}", calc="${ALPHA}", subsample="${READCOUNT}")"

# Cleaning up
rm "${OUTDIR}"/*rabund
