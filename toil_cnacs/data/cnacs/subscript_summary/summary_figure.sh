#! /bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly INPUTDIR=$1
readonly TAG=$2
readonly INPUT=$3
readonly PROBE_BED=$4
readonly TOTAL=$5

source ${CONFIG}
source ${UTIL}

check_num_args $# 5


# input files
readonly ARM_LENGTH=${CYTOBAND_DIR}/arm_length.txt
readonly CYTOBAND=${CYTOBAND_DIR}/cytoBand_rgb2.csv
readonly CENTROMERE=${CYTOBAND_DIR}/centromere_pos.txt


### main ###

# Relationship between total CNs and allele-specific CNs
echo "${R_PATH} --vanilla --slave --args ${INPUT} ${INPUTDIR}/${TAG}_summary/${TAG}.depth2as.pdf ${INPUTDIR}/${TAG}_summary/${TAG}.depth2as_inv.pdf < ${COMMAND_CNACS}/subscript_summary/depth2as.R"
${R_PATH} --vanilla --slave --args ${INPUT} ${INPUTDIR}/${TAG}_summary/${TAG}.depth2as.pdf ${INPUTDIR}/${TAG}_summary/${TAG}.depth2as_inv.pdf < ${COMMAND_CNACS}/subscript_summary/depth2as.R


# Ratio of size of CNA to a chromosome arm
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_summary/arm_ratio.pl ${INPUT} ${ARM_LENGTH} \
> ${INPUTDIR}/${TAG}_summary/${TAG}.arm_ratio.tmp.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_summary/arm_ratio.pl ${INPUT} ${ARM_LENGTH} \
> ${INPUTDIR}/${TAG}_summary/${TAG}.arm_ratio.tmp.txt

echo "${R_PATH} --vanilla --slave --args ${INPUTDIR}/${TAG}_summary/${TAG}.arm_ratio.tmp.txt ${INPUTDIR}/${TAG}_summary/${TAG}.arm_ratio.pdf Ratio_to_chromosome_arms < ${COMMAND_CNACS}/subscript_summary/hist.R"
${R_PATH} --vanilla --slave --args ${INPUTDIR}/${TAG}_summary/${TAG}.arm_ratio.tmp.txt ${INPUTDIR}/${TAG}_summary/${TAG}.arm_ratio.pdf Ratio_to_chromosome_arms < ${COMMAND_CNACS}/subscript_summary/hist.R


# Integrative view for each chromosome
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_summary/proc_integrative1.pl ${INPUT} ${INPUTDIR}/${TAG}_summary/${TAG}.gain_tmp.txt ${INPUTDIR}/${TAG}_summary/${TAG}.loss_tmp.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_summary/proc_integrative1.pl ${INPUT} ${INPUTDIR}/${TAG}_summary/${TAG}.gain_tmp.txt ${INPUTDIR}/${TAG}_summary/${TAG}.loss_tmp.txt

for i in `seq 1 22`
do
	echo "${R_PATH} --vanilla --slave --args ${INPUTDIR}/${TAG}_summary/${TAG}.gain_tmp.txt ${INPUTDIR}/${TAG}_summary/${TAG}.loss_tmp.txt ${CYTOBAND} ${INPUTDIR}/${TAG}_summary/${TAG}.chr${i}.pdf ${i} < ${COMMAND_CNACS}/subscript_summary/integrative1.R"
	${R_PATH} --vanilla --slave --args ${INPUTDIR}/${TAG}_summary/${TAG}.gain_tmp.txt ${INPUTDIR}/${TAG}_summary/${TAG}.loss_tmp.txt ${CYTOBAND} ${INPUTDIR}/${TAG}_summary/${TAG}.chr${i}.pdf ${i} < ${COMMAND_CNACS}/subscript_summary/integrative1.R
done

echo "${R_PATH} --vanilla --slave --args ${INPUTDIR}/${TAG}_summary/${TAG}.gain_tmp.txt ${INPUTDIR}/${TAG}_summary/${TAG}.loss_tmp.txt ${CYTOBAND} ${INPUTDIR}/${TAG}_summary/${TAG}.chrX.pdf 23 < ${COMMAND_CNACS}/subscript_summary/integrative1.R"
${R_PATH} --vanilla --slave --args ${INPUTDIR}/${TAG}_summary/${TAG}.gain_tmp.txt ${INPUTDIR}/${TAG}_summary/${TAG}.loss_tmp.txt ${CYTOBAND} ${INPUTDIR}/${TAG}_summary/${TAG}.chrX.pdf 23 < ${COMMAND_CNACS}/subscript_summary/integrative1.R


# Integrative view for all the chromosomes
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_summary/proc_integrative2.pl ${INPUT} ${PROBE_BED} ${TOTAL} \
> ${INPUTDIR}/${TAG}_summary/${TAG}.genome_tmp.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_summary/proc_integrative2.pl ${INPUT} ${PROBE_BED} ${TOTAL} \
> ${INPUTDIR}/${TAG}_summary/${TAG}.genome_tmp.txt

echo "${R_PATH} --vanilla --slave --args ${INPUTDIR}/${TAG}_summary/${TAG}.genome_tmp.txt ${CENTROMERE} ${INPUTDIR}/${TAG}_summary/${TAG}.genome.pdf < ${COMMAND_CNACS}/subscript_summary/integrative2.R"
${R_PATH} --vanilla --slave --args ${INPUTDIR}/${TAG}_summary/${TAG}.genome_tmp.txt ${CENTROMERE} ${INPUTDIR}/${TAG}_summary/${TAG}.genome.pdf < ${COMMAND_CNACS}/subscript_summary/integrative2.R


echo "rm ${INPUTDIR}/${TAG}_summary/${TAG}.arm_ratio.tmp.txt"
echo "rm ${INPUTDIR}/${TAG}_summary/${TAG}.gain_tmp.txt"
echo "rm ${INPUTDIR}/${TAG}_summary/${TAG}.loss_tmp.txt"
echo "rm ${INPUTDIR}/${TAG}_summary/${TAG}.genome_tmp.txt"
rm ${INPUTDIR}/${TAG}_summary/${TAG}.arm_ratio.tmp.txt
rm ${INPUTDIR}/${TAG}_summary/${TAG}.gain_tmp.txt
rm ${INPUTDIR}/${TAG}_summary/${TAG}.loss_tmp.txt
rm ${INPUTDIR}/${TAG}_summary/${TAG}.genome_tmp.txt
