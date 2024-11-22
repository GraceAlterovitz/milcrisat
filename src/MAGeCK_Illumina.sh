#!/bin/bash

# Source Conda initilization script
#source ~/miniconda3/pkgs/conda-24.4.0-py310h06a4308_0/lib/python3.10/site-packages/conda/shell/etc/profile.d/conda.sh
source ~/miniconda3/etc/profile.d/conda.sh

# Activate environment
#. ~/.conda_init
conda activate mageckenv
echo "Conda environment 'mageckenv' activated."
mageck || echo "Error: mageck command not found"

# Check if at least 6 arguments are provided
if [ "$#" -lt 6 ]; then
    echo "Usage: $0 <home_directory> <MAGeCK_count_output_name> <flanking_seq> <sample_label> <MAGeCK_test_sample_sheet> <fastq_files...>"
    exit 1
fi

HOME_DIR="$1"
MAGeCK_count_OUTPUT_NAME="$2"
FLANKING_SEQ="$3"
SAMPLE_LABEL="$4"
SAMPLE_SHEET="$5"
FASTQ_FILES="${@:6}"
#SAMPLE_SHEET="$HOME_DIR/input/sample_sheet.txt"

echo " "
echo " "
echo "Home Directory: $HOME_DIR"
echo "MAGecK count Output Name: $MAGeCK_count_OUTPUT_NAME"
echo "Flanking Seq: $FLANKING_SEQ"
echo "Sample Label: $SAMPLE_LABEL"
echo "MAGeCK Test Sample Sheet: $SAMPLE_SHEET"
echo "   "

: << 'END'
#echo "Illumina Amplicon sgRNA Analysis Pipeline"
#echo "Step 1: QC check using FastP and MultiQC..."
#mkdir -p "$HOME_DIR/output/fastqc/illumina"
#mkdir -p "$HOME_DIR/output/multiqc/illumina"
#fastqc -t 8 $FASTQ_FILES -o "$HOME_DIR/output/fastqc/illumina"
#multiqc "$HOME_DIR/output/fastqc/illumina" -o "$HOME_DIR/output/multiqc/illumina"

#echo "Step 2: Run Seqkit to remove reads with averaged quality score < 16..."
mkdir -p "$HOME_DIR/intermediate_data/illumina/seqkit"
for FILE in $FASTQ_FILES; do
    BASENAME=$(basename "$FILE" .fastq)
    seqkit seq "$FILE" -Q 16 -j 8 -o "$HOME_DIR/intermediate_data/illumina/seqkit/${BASENAME}_AvgQ16.fastq"
done

echo "Step 3: Use Cutadapt to remove the adaptor sequences and do 5'/3' trimming if quality score < 30..."
mkdir -p "$HOME_DIR/intermediate_data/illumina/cutadapt"
for FILE in "$HOME_DIR/intermediate_data/illumina/seqkit/*_AvgQ16.fastq"; do
    # Expand the wildcard using a globbing pattern
    for FASTQ_FILE in $FILE; do
        BASENAME=$(basename "$FASTQ_FILE" _AvgQ16.fastq)
        cutadapt -g "$FLANKING_SEQ" --action=trim --discard-untrimmed -j 8 -q 30,30 -o "$HOME_DIR/intermediate_data/illumina/cutadapt/${BASENAME}_53trimmedQ30.fastq" "$FASTQ_FILE"
    done
done

echo "Step 4: MAGeCK count map sgRNAs to the library and normalize the counts..."
mkdir -p "$HOME_DIR/output/MAGeCK_count/illumina"
# Define FASTQ_1 and FASTQ_2 to match files with specific suffixes 
FASTQ_1=$(find "$HOME_DIR/intermediate_data/illumina/cutadapt/" -type f -name "*_R1.fastq.gz_53trimmedQ30.fastq " | tr '\n' ' ')
FASTQ_2=$(find "$HOME_DIR/intermediate_data/illumina/cutadapt/" -type f -name "*_R2.fastq.gz_53trimmedQ30.fastq " | tr '\n' ' ')
mageck count -l "$HOME_DIR/input/GeCKO_library/GeCKOv2_LibA.txt" -n "$HOME_DIR/output/MAGeCK_count/illumina/${OUTPUT_NAME}_MAGeCK_count" --sample-label "$SAMPLE_LABEL" --fastq FASTQ_1 --fastq-2 FASTQ_2 --norm-method total --pdf-report &

echo mageck count -l "$HOME_DIR/input/GeCKO_library/GeCKOv2_LibA.txt" \
    -n "$HOME_DIR/output/MAGeCK_count/illumina/${OUTPUT_NAME}_MAGeCK_count" \
    --sample-label "$SAMPLE_LABEL" \
    --fastq "$FASTQ_1" \
    --fastq-2 "$FASTQ_2" \
    --norm-method total \
    --pdf-report

# mageck count -l ../input/GeCKO_library/GeCKOv2_LibA.txt -n combined_normalized_total_GeCKO_A --sample-label Day-3,Day0,Day14_Raji_1,Day14_Raji_2,Day14_Raji_3,Day14_T_1,Day14_T_2,Day14_T_3,Day17_Raji_1,Day17_Raji_2,Day17_Raji_3,Day17_T_1,Day17_T_2,Day17_T_3 --fastq ../input/S1_CAR19-LibA_R1.fastq.gz ../input/S2_CAR19-LibA_R1.fastq.gz ../input/S3_CAR19-LibA-Rep-1_Raji_R1.fastq.gz ../input/S4_CAR19-LibA-Rep-2_Raji_R1.fastq.gz ../input/S5_CAR19-LibA-Rep-3_Raji_R1.fastq.gz ../input/S6_CAR19-LibA-Rep-1_T-Cell-Only_R1.fastq.gz ../input/S7_CAR19-LibA-Rep-2_T-Cell-Only_R1.fastq.gz ../input/S8_CAR19-LibA-Rep-3_T-Cell-Only_R1.fastq.gz ../input/S9_CAR19-LibA-Rep-1_Raji_R1.fastq.gz ../input/S10_CAR19-LibA-Rep-2_Raji_R1.fastq.gz ../input/S11_CAR19-LibA-Rep-3_Raji_R1.fastq.gz ../input/S12_CAR19-LibA-Rep-1_T-Cell-Only_R1.fastq.gz ../input/S13_CAR19-LibA-Rep-2_T-Cell-Only_R1.fastq.gz ../input/S14_CAR19-LibA-Rep-3_T-Cell-Only_R1.fastq.gz --fastq-2 ../input/S1_CAR19-LibA_R2.fastq.gz ../input/S2_CAR19-LibA_R2.fastq.gz ../input/S3_CAR19-LibA-Rep-1_Raji_R2.fastq.gz ../input/S4_CAR19-LibA-Rep-2_Raji_R2.fastq.gz ../input/S5_CAR19-LibA-Rep-3_Raji_R2.fastq.gz ../input/S6_CAR19-LibA-Rep-1_T-Cell-Only_R2.fastq.gz ../input/S7_CAR19-LibA-Rep-2_T-Cell-Only_R2.fastq.gz ../input/S8_CAR19-LibA-Rep-3_T-Cell-Only_R2.fastq.gz ../input/S9_CAR19-LibA-Rep-1_Raji_R2.fastq.gz ../input/S10_CAR19-LibA-Rep-2_Raji_R2.fastq.gz ../input/S11_CAR19-LibA-Rep-3_Raji_R2.fastq.gz ../input/S12_CAR19-LibA-Rep-1_T-Cell-Only_R2.fastq.gz ../input/S13_CAR19-LibA-Rep-2_T-Cell-Only_R2.fastq.gz ../input/S14_CAR19-LibA-Rep-3_T-Cell-Only_R2.fastq.gz --norm-method total --pdf-report

END

echo "Step 5: MAGeCK test using MAGecK test sample sheet to initiate pairwise comparisons..."
mkdir -p "$HOME_DIR/output/MAGeCK_test/illumina"
# Read each line from the sample sheet (skip header)
tail -n +2 "$SAMPLE_SHEET" | while read -r OUTPUT_NAME TREATMENT_SAMPLE CONTROL_SAMPLE; do
    echo "Running MAGeCK test for $OUTPUT_NAME with treatment: $TREATMENT_SAMPLE and control: $CONTROL_SAMPLE"
    mageck test -k "$HOME_DIR/output/MAGeCK_count/illumina/${MAGeCK_count_OUTPUT_NAME}.count.txt" \
                 -t "$TREATMENT_SAMPLE" -c "$CONTROL_SAMPLE" \
                 --norm-method total \
                 -n "$HOME_DIR/output/MAGeCK_test/illumina/${OUTPUT_NAME}_MAGeCK_test" \
                 --pdf-report
done


