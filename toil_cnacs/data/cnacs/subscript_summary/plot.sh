#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly OUTPUTDIR=$1
readonly SEGMENT_ORG=$2

source ${CONFIG}
source ${UTIL}

check_num_args $# 2

readonly SEQBAM=`head -n ${SGE_TASK_ID} ${OUTPUTDIR}/bam_list.txt | tail -n 1`
TMP_ID="${SEQBAM##*/}"
ID=`echo ${TMP_ID} | sed -e "s/\.bam//"`


readonly INPUT=${OUTPUTDIR}/${ID}/${ID}_signal.txt
readonly SEGMENT=${OUTPUTDIR}/plot_final/${ID}_result.txt
readonly BAF=${OUTPUTDIR}/${ID}/tmp/baf_all.txt
readonly OUTPUT_ALL=${OUTPUTDIR}/plot_final/${ID}_all.pdf
readonly CENTROMERE=${CYTOBAND_DIR}/centromere_pos.txt


# extract CNAs
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_summary/extractCNA.pl ${SEGMENT_ORG} ${ID} > ${SEGMENT}"
${PERL_PATH} ${COMMAND_CNACS}/subscript_summary/extractCNA.pl ${SEGMENT_ORG} ${ID} > ${SEGMENT}


# draw figures
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/proc_input_all.pl ${INPUT} ${SEGMENT} ${BAF} ${INPUT}.tmp ${SEGMENT}.tmp"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/proc_input_all.pl ${INPUT} ${SEGMENT} ${BAF} ${INPUT}.tmp ${SEGMENT}.tmp

echo "${R_PATH} --vanilla --slave --args ${INPUT}.tmp ${SEGMENT}.tmp ${CENTROMERE} ${OUTPUT_ALL} < ${COMMAND_CNACS}/subscript_target/plot_all.R"
${R_PATH} --vanilla --slave --args ${INPUT}.tmp ${SEGMENT}.tmp ${CENTROMERE} ${OUTPUT_ALL} < ${COMMAND_CNACS}/subscript_target/plot_all.R

MAX=`cut -f 3 ${INPUT} | sort -n | tail -n 1`
if [ ${MAX%.*} -gt 3 ]; then
	readonly OUTPUT_SCALED=${OUTPUTDIR}/plot_final/${ID}_scaled.pdf

	echo "${R_PATH} --vanilla --slave --args ${INPUT}.tmp ${SEGMENT}.tmp ${CENTROMERE} ${OUTPUT_SCALED} < ${COMMAND_CNACS}/subscript_target/plot_scaled.R"
	${R_PATH} --vanilla --slave --args ${INPUT}.tmp ${SEGMENT}.tmp ${CENTROMERE} ${OUTPUT_SCALED} < ${COMMAND_CNACS}/subscript_target/plot_scaled.R
fi


echo "rm ${INPUT}.tmp"
echo "rm ${SEGMENT}"
echo "rm ${SEGMENT}.tmp"
rm ${INPUT}.tmp
rm ${SEGMENT}
rm ${SEGMENT}.tmp

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
