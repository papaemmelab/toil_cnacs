#!/bin/bash
#$ -S /bin/bash
#$ -cwd

readonly ORGDIR=$1
readonly BAF_FACTOR=$2
readonly SEQBAM=$3
readonly ID=$4
readonly COMMAND_CNACS=$5
readonly UTIL=$6

source ${UTIL}

check_num_args $# 6

# decide scaling factors for SNP-overlapping fragments
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/scaling_factor.pl ${BAF_FACTOR} ${ORGDIR}/${ID}/tmp/raw_baf.txt \
> ${ORGDIR}/${ID}/tmp/scaling_factor.txt"
echo ${CMD}
eval ${CMD}
check_error $?


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
