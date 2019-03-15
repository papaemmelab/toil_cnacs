#! /bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
write_usage() {
	echo ""
	echo "Usage: `basename $0` <information on global probes> <BED file of targeted regions> <tag> [<config>]"
	echo ""
}

readonly GLOBAL_PROBE=$1
readonly TARGET=$2
readonly TAG=$3
CONFIG=$4

DIR=`dirname ${0}`

# confirm right number of arguments
if [ $# -le 2 -o $# -ge 5 ]; then
	echo "wrong number of arguments"
	write_usage
	exit 1
fi

if [ $# -eq 3 ]; then
	CONFIG=${DIR}/../conf/hg19.env
fi

if [ $# -eq 4 ]; then
	if [ ! -f ${CONFIG} ]; then
		echo "${CONFIG} does not exist"
		write_usage
		exit 1
	fi
fi

# change the path name into absolute path
CONF_DIR=`dirname ${CONFIG}`
CONF_DIR=`echo $(cd ${CONF_DIR} && pwd)`
CONF_FILE="${CONFIG##*/}"
CONFIG=${CONF_DIR}/${CONF_FILE}

# import configuration files
source ${CONFIG}
source ${UTIL}


# check input files
check_file_exists ${GLOBAL_PROBE}
check_file_exists ${TARGET}


# check format of a BED file
${PERL_PATH} ${COMMAND_CNACS}/subscript_design/check_bed.pl ${GLOBAL_PROBE} ${AUTOSOME}
${PERL_PATH} ${COMMAND_CNACS}/subscript_design/check_bed.pl ${TARGET} ${AUTOSOME}


# make an output directory
${PERL_PATH} ${COMMAND_CNACS}/subscript_design/checkTagParam.pl ${TAG}
check_mkdir ${PROBEDIR}/${TAG}
check_mkdir ${PROBEDIR}/${TAG}/tmp


# make a log directory
readonly CURLOGDIR=${LOGDIR}/design/${TAG}
check_mkdir ${CURLOGDIR}
readonly LOGSTR=-e\ ${CURLOGDIR}\ -o\ ${CURLOGDIR}


# define job names
readonly SELECT_CAND=select_candidate.${TAG}


# select candidate SNPs
echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=2G,mem_req=2G -N ${SELECT_CAND} ${LOGSTR} ${COMMAND_CNACS}/subscript_design/selectCand.sh ${GLOBAL_PROBE} ${TARGET} ${TAG}"
qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=2G,mem_req=2G -N ${SELECT_CAND} ${LOGSTR} ${COMMAND_CNACS}/subscript_design/selectCand.sh ${GLOBAL_PROBE} ${TARGET} ${TAG}
