#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly ORGDIR=$1
readonly PROBE_BED=$2
readonly SEQBAM=$3
readonly ID=$4
readonly COMMAND_CNACS=$5
readonly UTIL=$6

source ${UTIL}
check_num_args $# 6

readonly FIRST_QUANT=`head -n 2 ${ORGDIR}/${ID}/tmp/length_stats.txt | tail -n 1`
readonly MEDIAN=`head -n 4 ${ORGDIR}/${ID}/tmp/length_stats.txt | tail -n 1`
readonly THIRD_QUANT=`head -n 6 ${ORGDIR}/${ID}/tmp/length_stats.txt | tail -n 1`


# divide a BED file according to fragments' length
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/divide_bed.pl ${ORGDIR}/${ID}/tmp/mapped.bed ${FIRST_QUANT} ${MEDIAN} ${THIRD_QUANT} ${ORGDIR}/${ID}/tmp/mapped_leng1.bed ${ORGDIR}/${ID}/tmp/mapped_leng2.bed ${ORGDIR}/${ID}/tmp/mapped_leng3.bed ${ORGDIR}/${ID}/tmp/mapped_leng4.bed"
echo ${CMD}
eval ${CMD}

echo "rm ${ORGDIR}/${ID}/tmp/mapped.bed"
rm ${ORGDIR}/${ID}/tmp/mapped.bed

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
