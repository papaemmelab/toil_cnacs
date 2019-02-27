#! /bin/bash
#$ -S /bin/bash
#$ -cwd


write_usage() {
	echo ""
	echo "Usage: `basename $0` [options] <tag> <BED file of SNP probes> [<config>]"
	echo ""
}

readonly INPUT=$1
readonly PROBE_BED=$2
readonly TOTAL=$3
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
check_file_exists ${INPUT}
INPUTDIR=`dirname ${INPUT}`

readonly ARM_LENGTH=${CYTOBAND_DIR}/arm_length.txt
readonly CYTOBAND=${CYTOBAND_DIR}/cytoBand_rgb2.csv
readonly CENTROMERE=${CYTOBAND_DIR}/centromere_pos.txt
readonly GENE_INFO=${CNACSDIR}/control/${CONTROL}/stats/gene_info.txt
check_file_exists ${ARM_LENGTH}
check_file_exists ${CYTOBAND}
check_file_exists ${CENTROMERE}

# tag for output files
FILE_NAME="${INPUT##*/}"
TAG=`echo ${FILE_NAME} | sed -e "s/\.sh//" | sed -e "s/\.txt$//"`

# an output directory
check_mkdir ${INPUTDIR}/${TAG}_summary

# make a log directory
readonly CURLOGDIR=${LOGDIR}/summary/${TAG}
check_mkdir ${CURLOGDIR}
readonly LOGSTR=-e\ ${CURLOGDIR}\ -o\ ${CURLOGDIR}

# job names
readonly DRAW_FIGURES=draw_figures.${TAG}

### main ###

# draw summary figures
echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=6G,mem_req=6G -N ${LOGSTR} ${COMMAND_CNACS}/subscript_summary/summary_figure.sh ${INPUTDIR} ${TAG} ${INPUT} ${PROBE_BED} ${TOTAL}"
qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=6G,mem_req=6G -N ${DRAW_FIGURES} ${LOGSTR} ${COMMAND_CNACS}/subscript_summary/summary_figure.sh ${INPUTDIR} ${TAG} ${INPUT} ${PROBE_BED} ${TOTAL}
