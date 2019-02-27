#!/bin/bash
#$ -S /bin/bash
#$ -cwd

readonly OUTPUTDIR=$1
readonly BAF_INFO=$2
readonly BAF_FACTOR=$3
readonly BAF_FACTOR_ALL=$4
readonly ALL_DEPTH=$5
readonly REP_TIME=$6

source ${CONFIG}
source ${UTIL}

check_num_args $# 6


readonly SEQBAM=`head -n ${SGE_TASK_ID} ${OUTPUTDIR}/bam_list.txt | tail -n 1`
TMP_ID="${SEQBAM##*/}"
ID=`echo ${TMP_ID} | sed -e "s/\.bam//"`


echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/add_cna.pl ${OUTPUTDIR}/${ID}/tmp/result_tmp2.txt ${OUTPUTDIR}/${ID}/tmp/cna_region.txt ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${ID}\
> ${OUTPUTDIR}/${ID}/tmp/result_tmp3.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/add_cna.pl ${OUTPUTDIR}/${ID}/tmp/result_tmp2.txt ${OUTPUTDIR}/${ID}/tmp/cna_region.txt ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${ID}\
> ${OUTPUTDIR}/${ID}/tmp/result_tmp3.txt


# additional UPDs
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/add_upd.pl ${OUTPUTDIR}/${ID}/tmp/baf_all.txt ${OUTPUTDIR}/${ID}/${ID}_signal.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp3.txt ${ID} > ${OUTPUTDIR}/${ID}/${ID}_result.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/add_upd.pl ${OUTPUTDIR}/${ID}/tmp/baf_all.txt ${OUTPUTDIR}/${ID}/${ID}_signal.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp3.txt ${ID} > ${OUTPUTDIR}/${ID}/${ID}_result.txt


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
