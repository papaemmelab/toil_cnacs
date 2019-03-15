#! /bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu

write_usage() {
	echo ""
	echo "Usage: `basename $0` [options] <tag> <BED file of SNP probes> [<config>]"
	echo ""
}

readonly INPUT=$1
CONFIG=$2

DIR=`dirname ${0}`

# confirm right number of arguments
if [ $# -le 0 -o $# -ge 3 ]; then
	echo "wrong number of arguments"
	write_usage
	exit 1
fi

if [ $# -eq 1 ]; then
	CONFIG=${DIR}/../conf/hg19.env
fi

if [ $# -eq 2 ]; then
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
check_file_exists ${INPUTDIR}/config.txt

readonly CONTROL=`head -n 1 ${INPUTDIR}/config.txt`
readonly PROBE_BED=`head -n 2 ${INPUTDIR}/config.txt | tail -n 1`
check_file_exists ${PROBE_BED}

readonly ARM_LENGTH=${CYTOBAND_DIR}/arm_length.txt
readonly CYTOBAND=${CYTOBAND_DIR}/cytoBand_rgb2.csv
readonly CENTROMERE=${CYTOBAND_DIR}/centromere_pos.txt
readonly GENE_INFO=${CNACSDIR}/control/${CONTROL}/stats/gene_info.txt
check_file_exists ${ARM_LENGTH}
check_file_exists ${CYTOBAND}
check_file_exists ${CENTROMERE}

# a total number of samples
TOTAL=`wc -l ${INPUTDIR}/bam_list.txt | cut -d " " -f 1`

# tag for output files
FILE_NAME="${INPUT##*/}"
TAG=`echo ${FILE_NAME} | sed -e "s/\.sh//" | sed -e "s/\.txt$//"`

# an output directory
check_mkdir ${INPUTDIR}/plot_final
check_mkdir ${INPUTDIR}/${TAG}_summary

# an output file for re-calculated signals
OUTPUT=${INPUTDIR}/${TAG}.processed.txt

# make a log directory
readonly CURLOGDIR=${LOGDIR}/summary/${TAG}
check_mkdir ${CURLOGDIR}
readonly LOGSTR=-e\ ${CURLOGDIR}\ -o\ ${CURLOGDIR}

# job names
readonly PROC_SIGNALS=proc_signals.${TAG}
readonly DRAW_PLOTS=draw_plots.${TAG}
readonly DRAW_FIGURES=draw_figures.${TAG}

### main ###

# re-calculate depths and BAFs for all the CNAs
echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=6G,mem_req=6G -N ${PROC_SIGNALS} ${LOGSTR} ${COMMAND_CNACS}/subscript_summary/calc_signals.sh ${INPUT} ${OUTPUT} ${GENE_INFO}"
qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=6G,mem_req=6G -N ${PROC_SIGNALS} ${LOGSTR} ${COMMAND_CNACS}/subscript_summary/calc_signals.sh ${INPUT} ${OUTPUT} ${GENE_INFO}

# draw plots of signals
echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${TOTAL}:1 -hold_jid ${PROC_SIGNALS} -N ${DRAW_PLOTS} ${LOGSTR} ${COMMAND_CNACS}/subscript_summary/plot.sh ${INPUTDIR} ${OUTPUT}"
qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${TOTAL}:1 -hold_jid ${PROC_SIGNALS} -N ${DRAW_PLOTS} ${LOGSTR} ${COMMAND_CNACS}/subscript_summary/plot.sh ${INPUTDIR} ${OUTPUT}

# draw summary figures
echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=6G,mem_req=6G -hold_jid ${PROC_SIGNALS} -N ${DRAW_FIGURES} ${LOGSTR} ${COMMAND_CNACS}/subscript_summary/summary_figure.sh ${INPUTDIR} ${TAG} ${OUTPUT} ${PROBE_BED} ${TOTAL}"
qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=6G,mem_req=6G -hold_jid ${PROC_SIGNALS} -N ${DRAW_FIGURES} ${LOGSTR} ${COMMAND_CNACS}/subscript_summary/summary_figure.sh ${INPUTDIR} ${TAG} ${OUTPUT} ${PROBE_BED} ${TOTAL}
