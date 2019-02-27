#!/bin/bash
#$ -S /bin/bash
#$ -cwd

readonly ORGDIR=$1
readonly PROBE_BED=$2
readonly SAMPLE_SEX=$3
readonly LENG_NUM=$4
readonly ID=$5
readonly MAX_FRAG_LENGTH=$6
readonly PAR_BED=$7
readonly COMMAND_CNACS=$8
readonly UTIL=$9

source ${UTIL}

check_num_args $# 9

LINE_NUM=`expr ${LENG_NUM} \\* 2 - 1`
readonly LENG=`head -n ${LINE_NUM} ${ORGDIR}/${ID}/tmp/length_stats.txt | tail -n 1`
echo ${LENG}

# calculate %GC for each target position (including flanking regions) for defined fragments' length
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/bait_gc_ref.pl ${ORGDIR}/sequence.fa ${MAX_FRAG_LENGTH} ${LENG} ${SAMPLE_SEX} ${PAR_BED} ${ORGDIR}/${ID}/tmp/pos2gc_leng${LENG_NUM}.txt ${ORGDIR}/${ID}/tmp/gc2num_leng${LENG_NUM}.txt"
echo ${CMD}
eval ${CMD}

# load %GC for each fragment
# calculate GC-stratified coverage
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/stratify_gc_ref.pl ${ORGDIR}/${ID}/tmp/mapped_leng${LENG_NUM}.bed ${ORGDIR}/${ID}/tmp/pos2gc_leng${LENG_NUM}.txt ${ORGDIR}/${ID}/tmp/gc2num_leng${LENG_NUM}.txt > ${ORGDIR}/${ID}/tmp/gc2rate_leng${LENG_NUM}.txt"
echo ${CMD}
eval ${CMD}
check_error $?

# predict numbers of mapped fragments for each region
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/extend_bed.pl ${PROBE_BED} ${LENG} | \
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/predict_depth_ref.pl ${ORGDIR}/${ID}/tmp/gc2rate_leng${LENG_NUM}.txt ${ORGDIR}/${ID}/tmp/pos2gc_leng${LENG_NUM}.txt ${LENG} ${SAMPLE_SEX} ${PAR_BED} \
> ${ORGDIR}/${ID}/tmp/predicted_depth_leng${LENG_NUM}.txt"
echo ${CMD}
eval ${CMD}

echo "rm ${ORGDIR}/${ID}/tmp/pos2gc_leng${LENG_NUM}.txt"
echo "rm ${ORGDIR}/${ID}/tmp/gc2num_leng${LENG_NUM}.txt"
rm ${ORGDIR}/${ID}/tmp/pos2gc_leng${LENG_NUM}.txt
rm ${ORGDIR}/${ID}/tmp/gc2num_leng${LENG_NUM}.txt

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
