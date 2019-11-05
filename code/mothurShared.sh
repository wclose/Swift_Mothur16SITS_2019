#! /bin/bash
# mothurShared.sh
# William L. Close

##################
# Set Script Env #
##################

# Set the variables to be used in this script
export SAMPLEDIR=${1:?ERROR: Need to define SAMPLEDIR.}
export SILVAV19=${2:?ERROR: Need to define SILVAV19.}
export RDPFASTA=${3:?ERROR: Need to define RDPFASTA.}
export RDPTAX=${4:?ERROR: Need to define RDPTAX.}

# Other variables
export OUTDIR=data/process/



###################
# Run QC Analysis #
###################

echo PROGRESS: Assembling, quality controlling, clustering, and classifying sequences.

# Making output dir
mkdir -p "${OUTDIR}"

# Making contigs from fastq.gz files, aligning reads to references, removing any non-bacterial sequences, assigning phylotypes, and creating shared file
mothur "#make.file(type=gz, inputdir="${SAMPLEDIR}", outputdir="${OUTDIR}");
	make.contigs(file=current);
	screen.seqs(fasta=current, group=current, maxambig=0, minlength=125, maxhomop=8);
	unique.seqs(fasta=current);
	count.seqs(name=current, group=current);
	align.seqs(fasta=current, reference="${SILVAV19}");
	filter.seqs(fasta=current, vertical=T);
	unique.seqs(fasta=current, count=current);
	pre.cluster(fasta=current, count=current, diffs=2);
	chimera.vsearch(fasta=current, count=current, dereplicate=T);
	remove.seqs(fasta=current, accnos=current);
	classify.seqs(fasta=current, count=current, reference="${RDPFASTA}", taxonomy="${RDPTAX}", cutoff=80);
	remove.lineage(fasta=current, count=current, taxonomy=current, taxon=Chloroplast-Mitochondria-unknown-Archaea-Eukaryota);
	phylotype(taxonomy=current);
	make.shared(list=current, count=current, label=1);
	classify.otu(list=current, count=current, taxonomy=current, label=1)"

# Renaming output files for use later
mv "${OUTDIR}"/*.tx.shared "${OUTDIR}"/final.shared
mv "${OUTDIR}"/*.tx.1.cons.taxonomy "${OUTDIR}"/final.taxonomy



###############
# Cleaning Up #
###############

echo PROGRESS: Cleaning up working directory.

# Making dir for storing intermediate files (can be deleted later)
mkdir -p "${OUTDIR}"/intermediate/

# Deleting unneccessary files
rm $(find "${OUTDIR}"/ -regex ".*filter.unique.precluster..*.fasta")
rm $(find "${OUTDIR}"/ -regex ".*filter.unique.precluster..*.map")
rm $(find "${OUTDIR}"/ -regex ".*filter.unique.precluster..*.count_table")

# Moving all remaining intermediate files to the intermediate dir
mv $(find "${OUTDIR}"/ -regex ".*\/stability.*") "${OUTDIR}"/intermediate
