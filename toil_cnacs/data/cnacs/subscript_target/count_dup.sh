#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly ORGDIR=$1
readonly SEQBAM=$2
readonly ID=$3
readonly COMMAND_CNACS=$4
readonly UTIL=$5

source ${UTIL}
check_num_args $# 5

readonly BAM=${ORGDIR}/${ID}/tmp/filt.bam

readonly FIRST_QUANT=`head -n 2 ${ORGDIR}/${ID}/tmp/length_stats.txt | tail -n 1`
readonly MEDIAN=`head -n 4 ${ORGDIR}/${ID}/tmp/length_stats.txt | tail -n 1`
readonly THIRD_QUANT=`head -n 6 ${ORGDIR}/${ID}/tmp/length_stats.txt | tail -n 1`


# count %duplicate for fragments with binned length
CMD="${SAMTOOLS_PATH}/samtools view ${BAM} | \
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/count_dup.pl ${FIRST_QUANT} ${MEDIAN} ${THIRD_QUANT} \
> ${ORGDIR}/${ID}/tmp/duplicate_stats.txt"
echo ${CMD}
eval ${CMD}

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
