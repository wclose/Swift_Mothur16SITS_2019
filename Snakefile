# Snakefile
# William L. Close

# Purpose: Snakemake 16S workflow for analyzing Swift Amplicon 16S™+ITS Panel data using mothur phylotype-based approach.

# Location of config file containing user-provided settings for analyzing data.
config: "config.yaml"

# Function for aggregating list of raw sequencing files.
mothurSamples = list(set(glob_wildcards(os.path.join('data/raw/', '{sample}_{readNum, R[12]}_001.fastq.gz')).sample))

# Master rule for controlling workflow.
rule all:
	input:
		expand("data/process/{group}.final.count.summary",
			group = config["mothurGroups"]),
		expand("data/process/{group}.final.0.03.subsample.shared",
			group = ['sample','mock']),
		"data/process/sample.final.groups.rarefaction",
		"data/process/sample.final.groups.ave-std.summary",
		expand("data/process/sample.final.{beta}.0.03.lt.ave.dist",
			beta = config["mothurBeta"]),
		expand("data/process/sample.final.{beta}.0.03.lt.ave.nmds.axes",
			beta = config["mothurBeta"]),
		expand("data/process/sample.final.{beta}.0.03.lt.ave.pcoa.axes",
			beta = config["mothurBeta"]),
		"data/process/error_analysis/errorinput.pick.error.summary"
	shell:
		"""
		mkdir -p logs/mothur/
		mv mothur*logfile logs/mothur/
		"""





##################################################################
#
# Part 1: Generate Reference Files
#
##################################################################

# Downloading and formatting SILVA and RDP reference databases. The v1-9 region is extracted from 
# SILVA database for use as reference alignment.
rule get16SReferences:
	input:
		script="code/mothurReferences.sh"
	output:
		silvaV19="data/references/silva.v19.align",
		rdpFasta="data/references/trainset16_022016.pds.fasta",
		rdpTax="data/references/trainset16_022016.pds.tax"
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script}"





##################################################################
#
# Part 2: Generate Shared Files 
#
##################################################################

# Generating master shared file using phylotype-based workflow.
rule make16SShared:
	input:
		script="code/mothurShared.sh",
		raw=expand('data/raw/{mothurSamples}_{readNum}_001.fastq.gz',
			mothurSamples = mothurSamples, readNum = config["readNum"]),
		refs=rules.get16SReferences.output
	output:
		shared="data/process/final.shared",
		taxonomy="data/process/final.taxonomy",
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script} data/raw/ {input.refs}"


# Splitting master shared file into individual shared file for: i) samples, ii) controls, and iii) mocks.
# This is used for optimal subsampling during downstream steps.
rule split16SShared:
	input:
		script="code/mothurSplitShared.sh",
		shared=rules.make16SShared.output.shared
	output:
		shared=expand("data/process/{group}.final.shared",
			group = config["mothurGroups"])
	params:
		controlGroups='-'.join(config["mothurControl"]), # Concatenates all control group names with hyphens
		mockGroups='-'.join(config["mothurMock"]) # Concatenates all mock group names with hyphens
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script} {params.mockGroups} {params.controlGroups}"


# Counting number of reads in each of the new shared files.
rule count16SShared:
	input:
		script="code/mothurCountShared.sh",
		shared="data/process/{group}.final.shared"
	output:
		count="data/process/{group}.final.count.summary"
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script} {input.shared}"


# Uses read counts to subsample shared files to the largest number of reads above a given read
# threshold denoted as 'subthresh'.
rule subsample16SShared:
	input:
		script="code/mothurSubsampleShared.sh",
		shared="data/process/{group}.final.shared",
		count="data/process/{group}.final.count.summary"
	output:
		subsampleShared="data/process/{group}.final.0.03.subsample.shared"
	params:
		subthresh=config["subthresh"]
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script} {input.shared} {input.count} {params.subthresh}"





##################################################################
#
# Part 3: Diversity Metrics 
#
##################################################################

# Calculating alpha diversity metrics (within sample diversity).
rule calc16SAlphaDiversity:
	input:
		script="code/mothurAlpha.sh",
		shared="data/process/sample.final.shared",
		count="data/process/sample.final.count.summary"
	output:
		alpha="data/process/sample.final.groups.ave-std.summary"
	params:
		subthresh=config["subthresh"],
		alpha='-'.join(config["mothurAlpha"]) # Concatenates all alpha metric names with hyphens
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script} {input.shared} {input.count} {params.subthresh} {params.alpha}"


# Calculating beta diversity metrics (between sample diversity).
rule calc16SBetaDiversity:
	input:
		script="code/mothurBeta.sh",
		shared="data/process/sample.final.shared",
		count="data/process/sample.final.count.summary"
	output:
		dist=expand("data/process/sample.final.{beta}.0.03.lt.ave.dist",
			beta = config["mothurBeta"])
	params:
		subthresh=config["subthresh"],
		beta='-'.join(config["mothurBeta"]) # Concatenates all beta metric names with hyphens
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script} {input.shared} {input.count} {params.subthresh} {params.beta}"





##################################################################
#
# Part 4: Ordination 
#
##################################################################

# Calculates principal coordinate analysis (PCoA) ordination for visualizing beta diversity.
rule calc16SPCoA:
	input:
		script="code/mothurPCoA.sh",
		dist="data/process/sample.final.{beta}.0.03.lt.ave.dist"
	output:
		loadings="data/process/sample.final.{beta}.0.03.lt.ave.pcoa.loadings",
		axes="data/process/sample.final.{beta}.0.03.lt.ave.pcoa.axes"
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script} {input.dist}"


# Calculates non-metric multi-dimensional scaling (NMDS) ordination for visualizing beta diversity. 
rule calc16SNMDS:
	input:
		script="code/mothurNMDS.sh",
		dist="data/process/sample.final.{beta}.0.03.lt.ave.dist"
	output:
		stress="data/process/sample.final.{beta}.0.03.lt.ave.nmds.stress",
		axes="data/process/sample.final.{beta}.0.03.lt.ave.nmds.axes"
	params:
		seed=config["seed"]
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script} {input.dist} {params.seed}"
