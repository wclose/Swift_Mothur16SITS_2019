## Snakemake 16S workflow for analyzing Swift Amplicon 16S™+ITS Panel data using mothur phylotype-based approach.

This repo can be used to generate all of the desired output files from mothur (shared, tax, alpha/beta diversity, ordiations, etc.). The workflow is designed to work with [Snakemake](https://snakemake.readthedocs.io/en/stable/) and [Conda](https://docs.conda.io/en/latest/) with minimal intervention by the user. If you want to know more about what the steps are and why we use them, you can read up on them at the [Mothur wiki](https://www.mothur.org/wiki/MiSeq_SOP).

### Usage

#### Dependencies
* MacOSX or Linux operating system.
* Install [Miniconda](https://docs.conda.io/en/latest/miniconda.html).
* Have paired end sequencing data.

<br />

#### Running analysis

**1.** Clone this repository to your computer/server and move into the project directory. This will download all of the scripts, etc. necessary to run the analysis.
```
git clone https://github.com/wclose/Swift_Mothur16SITS_2019.git
cd Swift_Mothur16SITS_2019/
```

<br />

**2.** Transfer all of your raw paired-end sequencing data into `data/raw/`. The repository comes with some test data already included so if you would like to see how the pipeline works, skip to **Step 3**.
> **NOTE:** Because of the way `mothur` parses sample names, it doesn't like it when you have hyphens or underscores in the **sample names** (emphasis on sample names, **not** the filename itself). There is a script (`code/mothurNames.sh`) you can use to change hyphens to something else. Feel free to modify it for removing extra underscores as needed.
>
> <br />
>
> E.g. a sequence file from mouse 10, day 10:  
> * **BAD** = *M10-10*_S91_L001_R1_001.fastq.gz  
> * **BAD** = *M10_10*_S91_L001_R1_001.fastq.gz  
> * **GOOD** = *M10D10*_S91_L001_R1_001.fastq.gz

<br />

Copy your sequencing files to the correct location.
```
cp PATH/TO/SEQUENCEDIR/* data/raw/
```

<br />

**3.** Create the master `snakemake` environment.
> **NOTE:** If you already have a conda environment with `snakemake` installed, you can skip this step.
```
conda env create -f envs/snakemake.yaml
```

<br />

**4.** Activate the environment that contains `snakemake`.
```
conda activate snakemake
```

<br />

**5.** Edit the options in [config.yaml](config.yaml) file to set downstream analysis options.
```
nano config.yaml
```

Things to change (everything else can/should be left as is):
* **mothurMock**: Put the names (just the names of the samples, not the full filename with all of the sequencer information) of all of your mock samples here. Make sure names don't have extra hyphens/underscorse as noted above.
* **mothurControl**: Sames as for the mocks, you'll want to put the names of your controls here. Make sure names don't have extra hyphens/underscorse as noted above.
* **mothurAlpha**: The names of the alpha diversity metrics you want calculated. More info [HERE](https://www.mothur.org/wiki/Summary.single). 
* **mothurBeta**: The names of the beta diversity metrics you want calculated. More info [HERE](https://www.mothur.org/wiki/Dist.shared).
* **subthresh**: The minimum number of reads to use for subsampling. The actual number used will be the smallest number of reads across all of your samples that are above this limit.

<br />

**6.** Test the workflow to make sure everything looks good. This will print a list of the commands to be executed without running them and will error if something isn't set properly.
```
snakemake -np
```

<br />

**7.** If you want to see how everything fits together, you can run the following to generate a flowchart of the various steps. Alternatively, we have included the [flowchart](dag.svg) for the test data to show how everything fits together. You may need to download the resulting image locally to view it properly.
> **NOTE:** If you are using MacOSX, you will need to install `dot` using [homebrew](https://brew.sh/) or some alternative process before running the following command.
```
snakemake --dag | dot -Tsvg > dag.svg
```

<br />

**8.** Run the workflow to generate the desired outputs. All of the results will be available in `data/process/` when the workflow is completed. Should something go wrong, all of the log files will be available in `logs/mothur/`.
```
snakemake --use-conda
```

<br />

**9.** If you wish to rerun the analysis, you can remove all of the ouput and run the workflow again.
```
snakemake clean
snakemake --use-conda
```
