#! /bin/bash
# mothurCountShared.sh
# William L. Close

##################
# Set Script Env #
##################

# Set the variables to be used in this script
export SHARED=${@:?ERROR: Need to define SHARED} # Shared file to be counted



#########################
# Counting Shared Files #
#########################

# Generating read count tables for shared files
echo PROGRESS: Generating read count tables.

# Counting each shared file individually
mothur "#count.groups(shared="${SHARED}")"
