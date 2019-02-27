#!/bin/bash
#$ -S /bin/bash
#$ -cwd

readonly ORGDIR=$1
readonly ID=$2
readonly COMMAND_CNACS=$3
readonly UTIL=$4

source ${UTIL}

check_num_args $# 4

# plot GC-stratified coverage
CMD="${R_PATH} --vanilla --slave --args ${ORGDIR}/${ID}/tmp/gc2rate_leng1.txt ${ORGDIR}/${ID}/tmp/gc2rate_leng2.txt ${ORGDIR}/${ID}/tmp/gc2rate_leng3.txt ${ORGDIR}/${ID}/tmp/gc2rate_leng4.txt ${ORGDIR}/${ID}/tmp/gc2rate.pdf \
< ${COMMAND_CNACS}/subscript_target/plotGC.R"
echo ${CMD}
eval ${CMD}


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
