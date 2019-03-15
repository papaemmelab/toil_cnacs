#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly ORGDIR=$1
readonly ID=$2
readonly COMMAND_CNACS=$3
readonly UTIL=$4

source ${UTIL}

check_num_args $# 4

echo "rm ${ORGDIR}/${ID}/tmp/filt.bam*"
echo "rm ${ORGDIR}/${ID}/tmp/mapped_leng*.bed"
rm ${ORGDIR}/${ID}/tmp/filt.bam*
rm ${ORGDIR}/${ID}/tmp/mapped_leng*.bed

# calculate ratio between actual and predicted depths
for LENG_NUM in `seq 1 4`
do
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/compare_depth.pl ${ORGDIR}/${ID}/tmp/predicted_depth_leng${LENG_NUM}.txt ${ORGDIR}/${ID}/tmp/actual_depth_leng${LENG_NUM}.txt \
> ${ORGDIR}/${ID}/tmp/depth_ratio_leng${LENG_NUM}.txt"
echo ${CMD}
eval ${CMD}
done

# estimate amplification efficiency and capture/sequence rate
# combine depth
CMD="${R_PATH} --vanilla --slave --args ${ORGDIR}/${ID}/tmp/depth_ratio_leng1.txt ${ORGDIR}/${ID}/tmp/depth_ratio_leng2.txt ${ORGDIR}/${ID}/tmp/depth_ratio_leng3.txt ${ORGDIR}/${ID}/tmp/depth_ratio_leng4.txt ${ORGDIR}/${ID}/tmp/duplicate_stats.txt ${ORGDIR}/${ID}/tmp/length_bias.txt ${ORGDIR}/${ID}/tmp/combined_depth.csv \
< ${COMMAND_CNACS}/subscript_target/estimate_rate.R"
echo ${CMD}
eval ${CMD}

CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/combine_depth.pl ${ORGDIR}/${ID}/tmp/combined_depth.csv ${ORGDIR}/${ID}/tmp/depth_ratio_leng1.txt \
> ${ORGDIR}/${ID}/tmp/combined_depth.txt"
echo ${CMD}
eval ${CMD}

echo "rm ${ORGDIR}/${ID}/tmp/combined_depth.csv"
rm ${ORGDIR}/${ID}/tmp/combined_depth.csv


# log_transformation
# normalization
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/norm_depth.pl ${ORGDIR}/${ID}/tmp/combined_depth.txt \
> ${ORGDIR}/${ID}/tmp/combined_normdep.txt"
echo ${CMD}
eval ${CMD}


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
