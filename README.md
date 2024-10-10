# milcrisat - Illumina Amplicon sgRNA Analysis Pipeline
   
**Introduction**

This pipeline is designed to enable standard QC, read trimming/filtering, read normalization and sgRNA read count in CRISPR-Cas9 genome-wide screening workflow. In current working pipeline, QC (fastqc, multiqc and nanoplot if Nanopore data), intermediate fastq files (seqkit and cutadapt) and MAGeCK count results will be outputted. 


**Usage**

1. Set up git environment in conda/mamba. 
Install associated Python libraries. MAGeCK_environment.yml includes all associated Python libraries.  

2. Create conda environment: conda env create -f MAGeCK_environment.yml

3. Git clone the source codes
Nanopore data: https://github.com/GraceAlterovitz/milcrisat.git
Illumina data:  

4. Run the BASH script
./MAGeCK_run.sh CURRENT_DIRECTORY SAMPLE_NAME


**Output**

1. All results and intermediate files will be populated under the output folder under CURRENT_DIRECTORY as default. 

2. Folder structure will be generated in a hierarchy as below.

-CURRENT_DIRECTORY
   -output
      -EPI2ME (if Nanopore)
      -nanoplot (if NanoPore)
      -fastqc
      -multiqc
      -MAGeCK_count
