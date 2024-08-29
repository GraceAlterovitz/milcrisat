#!/bin/bash
echo "Home Directory: $1"
echo "Samples: $2"
#$1 = ~/(\S+)(\.)fastq/
#echo "Sample name:"


echo "Nanopore Amplicon sgRNA Analysis Pipeline"
echo "Step 1: QC check using FastP and MultiQC...  "
mkdir $1/output
mkdir $1/output/fastqc
mkdir $1/output/multiqc
fastqc -t 8 $1/input/* -o $1/output/fastqc/
multiqc $1/output/fastqc -o $1/output/multiqc

echo "Step 2: Run Seqkit to remove reads with averaged quality score < 16..."
mkdir $1/intermediate_data/
#seqkit seq $PWD/input/$1__1.fastq.gz -Q 16 -j 8 -o $PWD/intermediate_data/$1__1_AvgQ16.fastq.gz
#seqkit seq $PWD/input/$1__2.fastq.gz -Q 16 -j 8 -o $PWD/intermediate_data/$1__2_AvgQ16.fastq.gz
seqkit seq $1/input/$2.fastq -Q 16 -j 8 -o $1/intermediate_data/$2_AvgQ16.fastq

echo "Step 3: Use Cutadapt to remove the adaptor sequences and do 5'/3' trimming if quality score < 30..." 
#cutadapt -g CTTGTGGAAAGGACGAAACACCG...GTTTTAGAGCT --action=trim --discard-untrimmed -j 8 -q 30,30 -o $PWD/intermediate_data/$1__1_AvgQ16_53trimmedQ30.fastq.gz -p $PWD/intermediate_data/$1__2_AvgQ16_53trimmedQ30.fastq.gz $PWD/intermediate_data/$1__1_AvgQ16.fastq.gz $PWD/intermediate_data/$1__2_AvgQ16.fastq.gz
cutadapt -g GCTTTATATATCTTGTGGAAAGGACGAAACACCG...GTTTTAGAGCTAGAAATAGCAAGTTAAAATAAGGCTAGTCCGTTATCAACTTGAAAAAGTGGCACCGAGTCGG --action=trim --discard-untrimmed -j 8 -q 30,30 -o $1/intermediate_data/$2_AvgQ16_53trimmedQ30.fastq $1/intermediate_data/$2_AvgQ16.fastq

echo "Step 4: MAGeCK count..."
mkdir $1/output/MAGeCK_count
mageck count -l $1/input/GeCKO_library/Lib-AB-combined.txt -n $1/output/MAGeCK_count/$2_MAGeCK_count --sample $2 --fastq $1/intermediate_data/$2_AvgQ16_53trimmedQ30.fastq --norm-method total --pdf-report &
