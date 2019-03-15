#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly ORGDIR=$1
readonly BAIT_GC=$2
readonly ID=$3
readonly COMMAND_CNACS=$4
readonly UTIL=$5

source ${UTIL}

check_num_args $# 5

echo "cp ${ORGDIR}/${ID}/tmp/combined_depth.txt ${ORGDIR}/${ID}/tmp/combined_depth.pre_wga.txt"
cp ${ORGDIR}/${ID}/tmp/combined_depth.txt ${ORGDIR}/${ID}/tmp/combined_depth.pre_wga.txt

CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/correct_wga.pl ${ORGDIR}/${ID}/tmp/combined_depth.pre_wga.txt ${BAIT_GC} ${ORGDIR}/${ID}/tmp/combined_depth.txt ${ORGDIR}/${ID}/tmp/gc2rate_wga.txt"
echo ${CMD}
eval ${CMD}

echo "rm ${ORGDIR}/${ID}/tmp/combined_depth.pre_wga.txt"
rm ${ORGDIR}/${ID}/tmp/combined_depth.pre_wga.txt


# plot GC-stratified coverage
CMD="${R_PATH} --vanilla --slave --args ${ORGDIR}/${ID}/tmp/gc2rate_wga.txt ${ORGDIR}/${ID}/tmp/gc2rate_wga.pdf \
< ${COMMAND_CNACS}/subscript_target/plotGC_wga.R"
echo ${CMD}
eval ${CMD}


# log_transformation
# normalization
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/norm_depth_ref.pl ${ORGDIR}/${ID}/tmp/combined_depth.txt \
> ${ORGDIR}/${ID}/tmp/combined_normdep.txt"
echo ${CMD}
eval ${CMD}


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
