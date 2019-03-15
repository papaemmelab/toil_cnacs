#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly ORGDIR=$1
readonly PROBE_BED=$2
readonly SEQBAM=$3
readonly ID=$4
readonly BASE_QUALITY_THRESHOLD=$5
readonly GENREF=$6
readonly UPD_ERROR=$7
readonly COMMAND_CNACS=$8
readonly UTIL=$9

source ${UTIL}
check_num_args $# 9

check_mkdir ${ORGDIR}/${ID}/tmp

# pileup
CMD="${SAMTOOLS_PATH}/samtools mpileup -BQ0 -d 10000000 -f ${GENREF} ${ORGDIR}/${ID}/tmp/filt.bam | \
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/pileup2base.pl ${BASE_QUALITY_THRESHOLD} ${ORGDIR}/overlapping_snp.bed \
> ${ORGDIR}/${ID}/tmp/base_count.txt"
echo ${CMD}
eval ${CMD}

# calculate BAF and filter SNPs
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/filterBase.pl ${ORGDIR}/${ID}/tmp/base_count.txt ${UPD_ERROR} > ${ORGDIR}/${ID}/tmp/raw_baf.txt"
echo ${CMD}
eval ${CMD}
check_error $?

echo "rm ${ORGDIR}/${ID}/tmp/base_count.txt"
rm ${ORGDIR}/${ID}/tmp/base_count.txt

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
