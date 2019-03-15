#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly ORGDIR=$1
readonly PROBE_BED=$2
readonly ALL_BED=$3
readonly MAX_FRAG_LENGTH=$4
readonly GENREF=$5
readonly REPLI_TIME=$6
readonly COMMAND_CNACS=$7
readonly UTIL=$8

source ${UTIL}
check_num_args $# 8

# select SNPs in the target regions
CMD="cut -f 1-3 ${PROBE_BED} | \
${BEDTOOLS_PATH}/intersectBed -a ${ALL_BED} -b stdin -wa -wb > \
${ORGDIR}/overlapping_snp.bed"

echo ${CMD}
eval ${CMD}

# obtain sequences of target regions (including flanking regions)
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/extend_bed.pl ${PROBE_BED} ${MAX_FRAG_LENGTH} | \
${BEDTOOLS_PATH}/fastaFromBed -fi ${GENREF} -bed stdin -fo ${ORGDIR}/sequence.fa -name"

echo ${CMD}
eval ${CMD}

# obtain information on replication timing
CMD="cut -f 1-3 ${PROBE_BED} | \
${BEDTOOLS_PATH}/intersectBed -a stdin -b ${REPLI_TIME} -wa -wb | \
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/repli_time.pl ${PROBE_BED} \
> ${ORGDIR}/repli_time.txt"

echo ${CMD}
eval ${CMD}

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
