#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly OUTPUTDIR=$1
readonly ID=$2

source ${CONFIG}
source ${UTIL}

check_num_args $# 2


readonly INPUT=${OUTPUTDIR}/${ID}/${ID}_signal.txt
readonly SEGMENT=${OUTPUTDIR}/${ID}/${ID}_result.txt
readonly BAF=${OUTPUTDIR}/${ID}/tmp/baf_all.txt
readonly OUTPUT_ALL=${OUTPUTDIR}/${ID}/${ID}_all.pdf
readonly OUTPUT_CHR=${OUTPUTDIR}/${ID}/${ID}_chr

readonly CYTOBAND=${CYTOBAND_DIR}/cytoBand_rgb2.csv
readonly CENTROMERE=${CYTOBAND_DIR}/centromere_pos.txt


# draw figures
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/proc_input_all.pl ${INPUT} ${SEGMENT} ${BAF} ${INPUT}.tmp ${SEGMENT}.tmp"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/proc_input_all.pl ${INPUT} ${SEGMENT} ${BAF} ${INPUT}.tmp ${SEGMENT}.tmp

echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/proc_input_chr.pl ${INPUT} ${SEGMENT} ${BAF} ${INPUT}.tmp2 ${SEGMENT}.tmp2"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/proc_input_chr.pl ${INPUT} ${SEGMENT} ${BAF} ${INPUT}.tmp2 ${SEGMENT}.tmp2


echo "${R_PATH} --vanilla --slave --args ${INPUT}.tmp ${SEGMENT}.tmp ${CENTROMERE} ${OUTPUT_ALL} < ${COMMAND_CNACS}/subscript_target/plot_all.R"
${R_PATH} --vanilla --slave --args ${INPUT}.tmp ${SEGMENT}.tmp ${CENTROMERE} ${OUTPUT_ALL} < ${COMMAND_CNACS}/subscript_target/plot_all.R

MAX=`cut -f 3 ${INPUT} | sort -n | tail -n 1`
if [ ${MAX%.*} -gt 3 ]; then
	readonly OUTPUT_SCALED=${OUTPUTDIR}/${ID}/${ID}_scaled.pdf

	echo "${R_PATH} --vanilla --slave --args ${INPUT}.tmp ${SEGMENT}.tmp ${CENTROMERE} ${OUTPUT_SCALED} < ${COMMAND_CNACS}/subscript_target/plot_scaled.R"
	${R_PATH} --vanilla --slave --args ${INPUT}.tmp ${SEGMENT}.tmp ${CENTROMERE} ${OUTPUT_SCALED} < ${COMMAND_CNACS}/subscript_target/plot_scaled.R
fi

for i in `seq 1 23`
do
	echo "${R_PATH} --vanilla --slave --args ${INPUT}.tmp2 ${SEGMENT}.tmp2 ${CYTOBAND} ${OUTPUT_CHR}${i}.pdf ${i} < ${COMMAND_CNACS}/subscript_target/plot_chr.R"
	${R_PATH} --vanilla --slave --args ${INPUT}.tmp2 ${SEGMENT}.tmp2 ${CYTOBAND} ${OUTPUT_CHR}${i}.pdf ${i} < ${COMMAND_CNACS}/subscript_target/plot_chr.R
done

echo "rm ${INPUT}.tmp"
echo "rm ${SEGMENT}.tmp"
echo "rm ${INPUT}.tmp2"
echo "rm ${SEGMENT}.tmp2"
rm ${INPUT}.tmp
rm ${SEGMENT}.tmp
rm ${INPUT}.tmp2
rm ${SEGMENT}.tmp2

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
