# milcrisat - Illumina Amplicon sgRNA Analysis Pipeline
   
**Introduction**

This pipeline is designed to streamline standard quality control, read trimming and filtering, sgRNA read counting, normalization, and identification of enriched or depleted genes in a CRISPR-Cas9 genome-wide screening workflow. The current implementation generates outputs for QC metrics (FastQC and MultiQC), intermediate FASTQ files (processed with SeqKit and Cutadapt), as well as results from MAGeCK count and MAGeCK test analyses.


**Usage**

1. Set up git environment in conda/mamba. 
Install associated Python libraries. MAGeCK_environment.yml includes all associated Python libraries.  

2. Create conda environment: conda env create -f MAGeCK_environment.yml

3. Git clone the source codes

4. Prepare sample_sheet.txt to summarize pairwise comparisons needed in the following format.

output_name	treatment_sample	control_sample
Treatment_1-vs-Control_1	Treatment_1	Control_1
Treatment_2-vs-Control_2	Treatment_2	Control_2

6. Run the BASH script
./MAGeCK_Illumina.sh CURRENT_WORK_DIRECTORY OUTPUT_NAME FLANKING_SEQ SAMPLE_NAME ALL_FASTQ_FILES...

/media/grace/project/test/milcrisat/src/MAGeCK_Illumina.sh /media/grace/project/test/milcrisat normalized_total_GeCKO_A GCTTTATATATCTTGTGGAAAGGACGAAACACCG...GTTTTAGAGCTAGAAATAGCAAGTTAAAATAAGGCTAGTCCGTTATCAACTTGAAAAAGTGGCACCGAGTCGG Control_1_R1, Control_1_R2, Control_2_R1, Control_2_R2, Treatment_1_R1, Treatment_1_R2, Treatment_2_R1, Treatment_2_R2 ../input/fastq/illumina/sample_sheet.txt ../input/fastq/illumina/Control_1_R1.fastq.gz ../input/fastq/illumina/Control_1_R2.fastq.gz ../input/fastq/illumina/Control_2_R1.fastq.gz ../input/fastq/illumina/Control_2_R2.fastq.gz ../input/fastq/illumina/Treatment_1_R1.fastq.gz ../input/fastq/illumina/Treatment_1_R2.fastq.gz ../input/fastq/illumina/Treatment_2_R1.fastq.gz ../input/fastq/illumina/Treatment_2_R2.fastq.gz



**Output**

1. All outputs and intermediate files will be populated under CURRENT_WORK_DIRECTORY as default. 

2. Folder structure will be generated in a hierarchy as below.

-CURRENT_WORK_DIRECTORY
   -input
      -sgRNA_library
      -fastq
         -illumina
   -intermediate_data
   -output
      -fastqc
      -multiqc
      -MAGeCK_count
      -MAGeCK_test
   -src
      
