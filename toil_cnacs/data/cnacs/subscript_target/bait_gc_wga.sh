#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly ORGDIR=$1
readonly PROBE_BED=$2
readonly WGA_LENGTH=$3
readonly GENREF=$4
readonly COMMAND_CNACS=$5
readonly UTIL=$6

source ${UTIL}

check_num_args $# 6

# obtain sequences of target regions (including flanking regions)
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/extend_bed_wga.pl ${PROBE_BED} ${WGA_LENGTH} | \
${BEDTOOLS_PATH}/fastaFromBed -fi ${GENREF} -bed stdin -fo ${ORGDIR}/sequence_wga.fa -name"
echo ${CMD}
eval ${CMD}

# calculate %GC for each probe
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/bait_gc_wga.pl ${ORGDIR}/sequence_wga.fa > ${ORGDIR}/bait_gc.txt"
echo ${CMD}
eval ${CMD}

echo "rm ${ORGDIR}/sequence_wga.fa"
rm ${ORGDIR}/sequence_wga.fa

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
