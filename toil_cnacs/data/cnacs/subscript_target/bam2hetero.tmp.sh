#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly ORGDIR=$1
readonly SNP_BED=$2
readonly BAF_INFO=$3

source ${CONFIG}
source ${UTIL}

check_num_args $# 3

readonly SEQBAM=`head -n ${SGE_TASK_ID} ${ORGDIR}/bam_list.txt | tail -n 1`
TMP_ID="${SEQBAM##*/}"
ID=`echo ${TMP_ID} | sed -e "s/\.bam//"`

check_mkdir ${ORGDIR}/${ID}/tmp



# adjust BAF
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/baf_adjust.pl ${ORGDIR}/${ID}/tmp/raw_baf.txt ${BAF_INFO} > ${ORGDIR}/${ID}/tmp/adjusted_baf.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/baf_adjust.pl ${ORGDIR}/${ID}/tmp/raw_baf.txt ${BAF_INFO} > ${ORGDIR}/${ID}/tmp/adjusted_baf.txt


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
