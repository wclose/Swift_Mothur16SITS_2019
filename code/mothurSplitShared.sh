#! /bin/bash
# mothurSplitShared.sh
# William L. Close

##################
# Set Script Env #
##################

# Set the variables to be used in this script
export MOCKGROUPS=$1 # List of mock groups in raw data dir separated by '-'
export CONTROLGROUPS=$2 # List of control groups in raw data dir separated by '-'

# Other variables
export OUTDIR=data/process/

# Making list of all non-sample groups for removal from master shared file. Combines CONTROLGROUPS 
# and MOCKGROUPS inputs if both were specified as inputs to script. If neither set of groups was
# specified, COMBINEDGROUPS will not be assigned/exist in shell.
if [ -n "${MOCKGROUPS}" -a -n "${CONTROLGROUPS}" ]; then
	
	# Combines the list of mock and control groups into a single string separated by '-'
	export COMBINEDGROUPS=$(echo "${MOCKGROUPS}"-"${CONTROLGROUPS}")

elif [ -n "${MOCKGROUPS}" ]; then

	export COMBINEDGROUPS=$(echo "${MOCKGROUPS}")

elif [ -n "${CONTROLGROUPS}" ]; then

	export COMBINEDGROUPS=$(echo "${CONTROLGROUPS}")

fi



####################################
# Make Group-Specific Shared Files #
####################################

# Sample shared file
echo PROGRESS: Creating sample shared file.

# If COMBINEDGROUPS has been defined above (meaning one or both of MOCKGROUPS and CONTROLGROUPS)
# was given as input, remove those groups from the master shared file to create the sample shared
# file.
if [ -n "${COMBINEDGROUPS}" ]; then

	# Removing all mock and control groups from shared file leaving only samples
	mothur "#remove.groups(shared="${OUTDIR}"/final.shared, groups="${COMBINEDGROUPS}")"

	# Renaming output file
	mv "${OUTDIR}"/final.1.pick.shared "${OUTDIR}"/sample.final.shared

# Else if none of those groups are specified, it is inferred that the master shared file only
# contains samples and no controls/mocks.
else

	# Renaming output file
	cp "${OUTDIR}"/final.shared "${OUTDIR}"/sample.final.shared

fi



# If MOCKGROUPS was defined as input, create a shared file containing only specified mock samples.
if [ -n "${MOCKGROUPS}" ]; then

	# Mock shared file
	echo PROGRESS: Creating mock shared file.

	# Removing non-mock groups from shared file
	mothur "#get.groups(shared="${OUTDIR}"/final.shared, groups="${MOCKGROUPS}")"

	# Renaming output file
	mv "${OUTDIR}"/final.1.pick.shared "${OUTDIR}"/mock.final.shared

fi



# If CONTROLGROUPS was defined as input, create a shared file containing only specified control samples.
if [ -n "${CONTROLGROUPS}" ]; then

	# Control shared file
	echo PROGRESS: Creating control shared file.

	# Removing any non-control groups from shared file
	mothur "#get.groups(shared="${OUTDIR}"/final.shared, groups="${CONTROLGROUPS}")"

	# Renaming output file
	mv "${OUTDIR}"/final.1.pick.shared "${OUTDIR}"/control.final.shared

fi
