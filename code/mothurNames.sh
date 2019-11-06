#! /bin/bash
# mothurNames.sh
# William L. Close

##################
# Set Script Env #
##################

# Set the variables to be used in this script
export SAMPLEDIR=${1:?ERROR: Need to define SAMPLEDIR.}

# Character(s) to be used in place of hyphens
export REPLACEMENT=$2 # Character to use when replacing hyphens



#####################
# Fixing File Names #
#####################

# Replacing hyphens in group names to prevent erros when running mothur later
echo PROGRESS: Fixing hyphens in sample names.

# For each fastq.gz in the $SAMPLEDIR
for FILE in $(ls "${SAMPLEDIR}" | grep "fastq"); do

	# Replace hyphens with the character specified above
	FILENAME=$(echo "${FILE}" | sed 's/-/'"${REPLACEMENT}"'/g')

	# Rename files using new format without hyphens
	mv "${SAMPLEDIR}"/"${FILE}" "${SAMPLEDIR}"/"${FILENAME}"

done
