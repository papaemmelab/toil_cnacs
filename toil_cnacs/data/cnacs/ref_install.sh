#! /bin/bash
#$ -S /bin/bash
#$ -cwd

write_usage() {
	echo ""
	echo "Usage: `basename $0` [options] <tag> <BED file of probes> [<config>]"
	echo ""
}

readonly TAG=$1
PROBE_BED=$2
TARGET_BED=$3

DIR=`dirname ${0}`
CONFIG=${DIR}/../conf/hg19/hg19.env

# confirm right number of arguments
if [ $# -le 1 -o $# -ge 4 ]; then
	echo "wrong number of arguments"
	write_usage
	exit 1
fi

# change the path name into absolute path
CONF_DIR=`dirname ${CONFIG}`
CONF_DIR=`echo $(cd ${CONF_DIR} && pwd)`
CONF_FILE="${CONFIG##*/}"
CONFIG=${CONF_DIR}/${CONF_FILE}

PROBE_DIR=`dirname ${PROBE_BED}`
PROBE_DIR=`echo $(cd ${PROBE_DIR} && pwd)`
PROBE_FILE="${PROBE_BED##*/}"
PROBE_BED=${PROBE_DIR}/${PROBE_FILE}


# import configuration files
source ${CONFIG}
source ${UTIL}


# check input files
check_file_exists ${PROBE_BED}

# check format of a BED file
${PERL_PATH} ${COMMAND_CNACS}/subscript_design/check_bed.pl ${PROBE_BED} ${AUTOSOME}

# check a bait size
BAIT_SIZE=`${PERL_PATH} ${COMMAND_CNACS}/subscript_target/bait_size.pl ${PROBE_BED} ${MODE_THRES}`
if [ ${BAIT_SIZE} -lt ${MODE_THRES} ]; then
	MODE=Targeted-seq
	SUBSCRIPT=subscript_target
	MEMORY=1
	TARGET=${PROBE_BED}
else
	MODE=Exome-seq
	SUBSCRIPT=subscript_exome
	MEMORY=1

	TARGET_DIR=`dirname ${TARGET_BED}`
	TARGET_DIR=`echo $(cd ${TARGET_DIR} && pwd)`
	TARGET_FILE="${TARGET_BED##*/}"
	TARGET=${TARGET_DIR}/${TARGET_FILE}
fi
echo "${MODE} mode will be applied."


# check an input directory
readonly ORGDIR=${CNACSDIR}/control/${TAG}

if [ ! -e  ${ORGDIR} ]; then
	echo "${ORGDIR} does not exist"
	write_usage
	exit 1
fi

# check a file specifying thresholds
THRESHOLD=${ORGDIR}/stats/threshold.txt
check_file_exists ${THRESHOLD}

# a directory for plots of bait distribution
check_mkdir ${ORGDIR}/stats/bait_dist

# make a log directory
readonly CURLOGDIR=${LOGDIR}/control/${TAG}
check_mkdir ${CURLOGDIR}
readonly LOGSTR=-e\ ${CURLOGDIR}\ -o\ ${CURLOGDIR}


# define job names
readonly INSTALL=ref_install.${TAG}


# Install information on probes
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=${MEMORY}G,mem_req=${MEMORY}G -N ${INSTALL} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/ref_install_main.sh ${ORGDIR} ${TARGET} ${THRESHOLD}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=${MEMORY}G,mem_req=${MEMORY}G -N ${INSTALL} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/ref_install_main.sh ${ORGDIR} ${TARGET} ${THRESHOLD}
echo bsub -W 89 -M ${MEMORY} -J "${INSTALL}" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/ref_install_main.sh ${ORGDIR} ${TARGET} ${THRESHOLD}
bsub -W 89 -M ${MEMORY} -J "${INSTALL}" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/ref_install_main.sh ${ORGDIR} ${TARGET} ${THRESHOLD}
