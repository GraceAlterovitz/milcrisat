#!/bin/bash
. ~/.conda_init
conda activate mageckenv

# Check if at least 4 arguments are provided
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <home_directory> <output_name> <flanking_seq> <fastq_files...>"
    exit 1
fi

HOME_DIR="$1"
OUTPUT_NAME="$2"
FLANKING_SEQ="$3"
FASTQ_FILES="${@:4}"

echo "Home Directory: $HOME_DIR"
echo "Output Name: $OUTPUT_NAME"
echo "Flanking Seq: $FLANKING_SEQ"
echo "   "


echo "Illumina Amplicon sgRNA Analysis Pipeline"
echo "Step 1: QC check using FastP and MultiQC..."
mkdir -p "$HOME_DIR/output/fastqc/illumina"
mkdir -p "$HOME_DIR/output/multiqc/illumina"
fastqc -t 8 $FASTQ_FILES -o "$HOME_DIR/output/fastqc/illumina"
multiqc "$HOME_DIR/output/fastqc/illumina" -o "$HOME_DIR/output/multiqc/illumina"

echo "Step 2: Run Seqkit to remove reads with averaged quality score < 16..."
mkdir -p "$HOME_DIR/intermediate_data/illumina"
for FILE in $FASTQ_FILES; do
    BASENAME=$(basename "$FILE" .fastq)
    seqkit seq "$FILE" -Q 16 -j 8 -o "$HOME_DIR/intermediate_data/illumina/${BASENAME}_AvgQ16.fastq"
done

echo "Step 3: Use Cutadapt to remove the adaptor sequences and do 5'/3' trimming if quality score < 30..."
for FILE in "$HOME_DIR/intermediate_data/illumina/*_AvgQ16.fastq"; do
    # Expand the wildcard using a globbing pattern
    for FASTQ_FILE in $FILE; do
        BASENAME=$(basename "$FASTQ_FILE" _AvgQ16.fastq)
        cutadapt -g "$FLANKING_SEQ" --action=trim --discard-untrimmed -j 8 -q 30,30 -o "$HOME_DIR/intermediate_data/illumina/${BASENAME}_53trimmedQ30.fastq" "$FASTQ_FILE"
    done
done
'

echo "Step 4: MAGeCK count..."
mkdir -p "$HOME_DIR/output/MAGeCK_count/illumina"
mageck count -l "$HOME_DIR/input/GeCKO_library/GeCKOv2_LibA.txt" -n "$HOME_DIR/output/MAGeCK_count/illumina/${OUTPUT_NAME}_MAGeCK_count" --sample "$OUTPUT_NAME" --fastq "$HOME_DIR/intermediate_data/illumina/*_53trimmedQ30.fastq" --norm-method total --pdf-report &
