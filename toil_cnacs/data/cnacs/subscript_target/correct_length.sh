#!/bin/bash
#$ -S /bin/bash
#$ -cwd

readonly ORGDIR=$1
readonly PROBE_BED=$2

source ${CONFIG}
source ${UTIL}

check_num_args $# 2

# readonly SEQBAM=`head -n ${SGE_TASK_ID} ${ORGDIR}/bam_list.txt | tail -n 1`
readonly SEQBAM=`head -n ${LSB_JOBINDEX} ${ORGDIR}/bam_list.txt | tail -n 1`
TMP_ID="${SEQBAM##*/}"
ID=`echo ${TMP_ID} | sed -e "s/\.bam//"`
ID2=`echo ${ID} | sed -e "s/s_//"`

echo "rm ${ORGDIR}/${ID}/tmp/filt.bam*"
echo "rm ${ORGDIR}/${ID}/tmp/mapped_leng*.bed"
rm ${ORGDIR}/${ID}/tmp/filt.bam*
rm ${ORGDIR}/${ID}/tmp/mapped_leng*.bed

# calculate ratio between actual and predicted depths
for LENG_NUM in `seq 1 4`
do
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/compare_depth.pl ${ORGDIR}/${ID}/tmp/predicted_depth_leng${LENG_NUM}.txt ${ORGDIR}/${ID}/tmp/actual_depth_leng${LENG_NUM}.txt \
> ${ORGDIR}/${ID}/tmp/depth_ratio_leng${LENG_NUM}.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/compare_depth.pl ${ORGDIR}/${ID}/tmp/predicted_depth_leng${LENG_NUM}.txt ${ORGDIR}/${ID}/tmp/actual_depth_leng${LENG_NUM}.txt \
> ${ORGDIR}/${ID}/tmp/depth_ratio_leng${LENG_NUM}.txt
done

# estimate amplification efficiency and capture/sequence rate
# combine depth
echo "${R_PATH} --vanilla --slave --args ${ORGDIR}/${ID}/tmp/depth_ratio_leng1.txt ${ORGDIR}/${ID}/tmp/depth_ratio_leng2.txt ${ORGDIR}/${ID}/tmp/depth_ratio_leng3.txt ${ORGDIR}/${ID}/tmp/depth_ratio_leng4.txt ${ORGDIR}/${ID}/tmp/duplicate_stats.txt ${ORGDIR}/${ID}/tmp/length_bias.txt ${ORGDIR}/${ID}/tmp/combined_depth.csv \
< ${COMMAND_CNACS}/subscript_target/estimate_rate.R"
${R_PATH} --vanilla --slave --args ${ORGDIR}/${ID}/tmp/depth_ratio_leng1.txt ${ORGDIR}/${ID}/tmp/depth_ratio_leng2.txt ${ORGDIR}/${ID}/tmp/depth_ratio_leng3.txt ${ORGDIR}/${ID}/tmp/depth_ratio_leng4.txt ${ORGDIR}/${ID}/tmp/duplicate_stats.txt ${ORGDIR}/${ID}/tmp/length_bias.txt ${ORGDIR}/${ID}/tmp/combined_depth.csv \
< ${COMMAND_CNACS}/subscript_target/estimate_rate.R

echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/combine_depth.pl ${ORGDIR}/${ID}/tmp/combined_depth.csv ${ORGDIR}/${ID}/tmp/depth_ratio_leng1.txt \
> ${ORGDIR}/${ID}/tmp/combined_depth.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/combine_depth.pl ${ORGDIR}/${ID}/tmp/combined_depth.csv ${ORGDIR}/${ID}/tmp/depth_ratio_leng1.txt \
> ${ORGDIR}/${ID}/tmp/combined_depth.txt

echo "rm ${ORGDIR}/${ID}/tmp/combined_depth.csv"
rm ${ORGDIR}/${ID}/tmp/combined_depth.csv


# log_transformation
# normalization
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/norm_depth.pl ${ORGDIR}/${ID}/tmp/combined_depth.txt \
> ${ORGDIR}/${ID}/tmp/combined_normdep.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/norm_depth.pl ${ORGDIR}/${ID}/tmp/combined_depth.txt \
> ${ORGDIR}/${ID}/tmp/combined_normdep.txt


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
