#! /bin/bash
#$ -S /bin/bash
#$ -cwd

readonly INPUT=$1
readonly OUTPUT=$2
readonly GENE_INFO=$3

source ${CONFIG}
source ${UTIL}

check_num_args $# 3

# an input directory
INPUTDIR=`dirname ${INPUT}`


### main ###
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_summary/calc_signals.pl ${INPUT} ${INPUTDIR} ${GENE_INFO} \
> ${OUTPUT}"
${PERL_PATH} ${COMMAND_CNACS}/subscript_summary/calc_signals.pl ${INPUT} ${INPUTDIR} ${GENE_INFO} \
> ${OUTPUT}
