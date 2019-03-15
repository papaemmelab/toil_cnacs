#! /bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
write_usage() {
	echo ""
	echo "Usage: `basename $0` [options] <tag of an input directory> <tag of control samples> <BED file of probes> [<config>]"
	echo ""
	echo "Options: -r process samples with whole-genome amplification"
	echo ""
}

flg_repliG="FALSE"
while getopts r opt
do
	case ${opt} in
	r) flg_repliG="TRUE";;
	\?)
		echo "invalid option"
		write_usage
		exit 1;;
	esac
done
shift `expr $OPTIND - 1`


readonly TAG=$1
readonly CONTROL=$2
PROBE_BED=$3
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

# check BED files
PROBE_DIR=`dirname ${PROBE_BED}`
PROBE_DIR=`echo $(cd ${PROBE_DIR} && pwd)`
PROBE_FILE="${PROBE_BED##*/}"
PROBE_BED=${PROBE_DIR}/${PROBE_FILE}
check_file_exists ${PROBE_BED}

readonly SNP_BED=${CNACSDIR}/control/${CONTROL}/overlapping_snp.bed
readonly REP_TIME=${CNACSDIR}/control/${CONTROL}/repli_time.txt
check_file_exists ${SNP_BED}
check_file_exists ${REP_TIME}

# check format of a BED file
${PERL_PATH} ${COMMAND_CNACS}/subscript_design/check_bed.pl ${PROBE_BED} ${AUTOSOME}

# check a bait size
BAIT_SIZE=`${PERL_PATH} ${COMMAND_CNACS}/subscript_target/bait_size.pl ${PROBE_BED} ${MODE_THRES}`
if [ ${BAIT_SIZE} -lt ${MODE_THRES} ]; then
	MODE=Targeted-seq
	SUBSCRIPT=subscript_target
else
	MODE=Exome-seq
	SUBSCRIPT=subscript_exome
fi
echo "${MODE} mode will be applied."


# check required files
readonly BAIT_FA=${CNACSDIR}/control/${CONTROL}/sequence.fa
readonly BAF_INFO=${CNACSDIR}/control/${CONTROL}/stats/baf_stats.txt
readonly BAF_FACTOR_ALL=${CNACSDIR}/control/${CONTROL}/stats/baf_factor.all.bed
readonly BAF_FACTOR=${CNACSDIR}/control/${CONTROL}/stats/baf_factor.bed
readonly ALL_DEPTH=${CNACSDIR}/control/${CONTROL}/stats/all_depth.txt
check_file_exists ${BAIT_FA}
check_file_exists ${BAF_INFO}
check_file_exists ${BAF_FACTOR_ALL}
check_file_exists ${BAF_FACTOR}
check_file_exists ${ALL_DEPTH}

readonly BAIT_GC=${CNACSDIR}/control/${CONTROL}/bait_gc.txt
if [ ${flg_repliG} = "TRUE" ]; then
	check_file_exists ${BAIT_GC}
fi


# check an input directory
readonly INPUTDIR=${INDIR}/${TAG}

if [ ! -e  ${INPUTDIR} ]; then
	echo "${INPUTDIR} does not exist"
	write_usage
	exit 1
fi

# make an output directory
OUTPUTDIR=${OUTDIR}/${TAG}
check_mkdir ${OUTPUTDIR}

# write information on configuration
echo -n > ${OUTPUTDIR}/config.txt
echo ${CONTROL} >> ${OUTPUTDIR}/config.txt
echo ${PROBE_BED} >> ${OUTPUTDIR}/config.txt
echo ${CONFIG} >> ${OUTPUTDIR}/config.txt


# make a log directory
readonly CURLOGDIR=${LOGDIR}/cnacs/${TAG}
check_mkdir ${CURLOGDIR}
readonly LOGSTR=-e\ ${CURLOGDIR}\ -o\ ${CURLOGDIR}

# collect information on sample names
find ${INPUTDIR} -maxdepth 2 -name "*.bam" > ${OUTPUTDIR}/bam_list.txt
FILECOUNT=`wc -l ${OUTPUTDIR}/bam_list.txt | cut -d " " -f 1`


### define job names
# PREPROCESSING
readonly PROC_BAM=proc_bam.${TAG}
readonly DIVIDE_BED=divide_bed.${TAG}

# PROCESSING INFORMATION ON BAF
readonly BAM2HETERO=bam2hetero.${TAG}

# COMPENSATION FOR LOW CAPTURE EFFICIENCY DUE TO MINOR ALLELE
readonly PROBE2SCALE=probe2scale.${TAG}
readonly CORRECT_BAF=correct_baf.${TAG}

# GC BIAS CORRECTION
readonly CORRECT_GC=correct_gc.${TAG}
readonly PLOT_GC=plot_gc.${TAG}

# CORRECTION OF FRAGMENT LENGTH BIAS
readonly COUNT_DUP=count_dup.${TAG}
readonly CORRECT_LENGTH=correct_length.${TAG}

# CORRECTION OF BIAS FROM WGA
readonly CORRECT_WGA=correct_wga.${TAG}

# CALCULATION OF MEAN DEPTH FOR EACH GENE
readonly GENE_DEPTH=gene_depth.${TAG}

# MAIN
readonly CNACS_MAIN=cnacs_main.${TAG}
readonly PLOT=plot.${TAG}

# SUMMARIZE
readonly CAT_RESULT=cat_result.${TAG}


##### PREPROCESSING #####

# process BAM files
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=8G,mem_req=8G -N ${PROC_BAM} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/proc_bam.sh ${OUTPUTDIR} ${PROBE_BED}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=8G,mem_req=8G -N ${PROC_BAM} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/proc_bam.sh ${OUTPUTDIR} ${PROBE_BED}
echo bsub -W 4000 -M 8 -J "${PROC_BAM}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/proc_bam.sh ${OUTPUTDIR} ${PROBE_BED}
bsub -W 4000 -M 8 -J "${PROC_BAM}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/proc_bam.sh ${OUTPUTDIR} ${PROBE_BED}

# divide BED files according to fragments' length
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PROC_BAM} -N ${DIVIDE_BED} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/divide_bed.sh ${OUTPUTDIR}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PROC_BAM} -N ${DIVIDE_BED} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/divide_bed.sh ${OUTPUTDIR}
echo bsub -W 89 -M 1 -w "done(${PROC_BAM}[*])" -J "${DIVIDE_BED}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/divide_bed.sh ${OUTPUTDIR}
bsub -W 89 -M 1 -w "done(${PROC_BAM}[*])" -J "${DIVIDE_BED}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/divide_bed.sh ${OUTPUTDIR}

##### END OF PREPROCESSING #####



##### PROCESSING INFORMATION ON BAF #####

# SNP typing
echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PROC_BAM} -N ${BAM2HETERO} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/bam2hetero.sh ${OUTPUTDIR} ${SNP_BED} ${BAF_INFO}"
qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PROC_BAM} -N ${BAM2HETERO} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/bam2hetero.sh ${OUTPUTDIR} ${SNP_BED} ${BAF_INFO}
echo bsub -W 89 -M 1 -w "done(${PROC_BAM}[*])" -J "${BAM2HETERO}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/bam2hetero.sh ${OUTPUTDIR} ${SNP_BED} ${BAF_INFO}
bsub -W 89 -M 1 -w "done(${PROC_BAM}[*])" -J "${BAM2HETERO}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/bam2hetero.sh ${OUTPUTDIR} ${SNP_BED} ${BAF_INFO}

##### END OF PROCESSING INFORMATION ON BAF #####



##### COMPENSATION FOR LOW CAPTURE EFFICIENCY DUE TO MINOR ALLELES  #####

# decide scaling factors for SNP-overlapping fragments
echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${BAM2HETERO} -N ${PROBE2SCALE} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/probe2scale.sh ${OUTPUTDIR} ${BAF_FACTOR}"
qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${BAM2HETERO} -N ${PROBE2SCALE} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/probe2scale.sh ${OUTPUTDIR} ${BAF_FACTOR}
echo bsub -M -W 89 1 -w "done(${BAM2HETERO}[*])" -J "${PROBE2SCALE}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/probe2scale.sh ${OUTPUTDIR} ${BAF_FACTOR}
bsub -W 89 -M 1 -w "done(${BAM2HETERO}[*])" -J "${PROBE2SCALE}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/probe2scale.sh ${OUTPUTDIR} ${BAF_FACTOR}


# compensate for low capture efficiency of fragments containing minor alleles
for i in `seq 1 4`
do
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PROBE2SCALE} -N ${CORRECT_BAF}_${i} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_baf.sh ${OUTPUTDIR} ${PROBE_BED} ${i} ${BAF_FACTOR_ALL}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PROBE2SCALE} -N ${CORRECT_BAF}_${i} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_baf.sh ${OUTPUTDIR} ${PROBE_BED} ${i} ${BAF_FACTOR_ALL}
echo bsub -W 89 -M 1 -w "done(${PROBE2SCALE}[*])" -J "${CORRECT_BAF}_${i}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_baf.sh ${OUTPUTDIR} ${PROBE_BED} ${i} ${BAF_FACTOR_ALL}
bsub -W 89 -M 1 -w "done(${PROBE2SCALE}[*])" -J "${CORRECT_BAF}_${i}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_baf.sh ${OUTPUTDIR} ${PROBE_BED} ${i} ${BAF_FACTOR_ALL}
done

##### END OF COMPENSATION FOR LOW CAPTURE EFFICIENCY DUE TO MINOR ALLELES  #####



##### GC BIAS CORRECTION #####

for i in `seq 1 4`
do
echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=5.3G,mem_req=5.3G -hold_jid ${DIVIDE_BED} -N ${CORRECT_GC}_${i} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/correct_gc.sh ${OUTPUTDIR} ${PROBE_BED} ${i} ${BAIT_FA}"
qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=5.3G,mem_req=5.3G -hold_jid ${DIVIDE_BED} -N ${CORRECT_GC}_${i} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/correct_gc.sh ${OUTPUTDIR} ${PROBE_BED} ${i} ${BAIT_FA}
echo bsub -W 89 -M 6 -w "done(${DIVIDE_BED}[*])" -J "${CORRECT_GC}_${i}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/correct_gc.sh ${OUTPUTDIR} ${PROBE_BED} ${i} ${BAIT_FA}
bsub -W 89 -M 6 -w "done(${DIVIDE_BED}[*])" -J "${CORRECT_GC}_${i}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/correct_gc.sh ${OUTPUTDIR} ${PROBE_BED} ${i} ${BAIT_FA}
done

# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${CORRECT_GC}_1,${CORRECT_GC}_2,${CORRECT_GC}_3,${CORRECT_GC}_4 -N ${PLOT_GC} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/plotGC.sh ${OUTPUTDIR}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${CORRECT_GC}_1,${CORRECT_GC}_2,${CORRECT_GC}_3,${CORRECT_GC}_4 -N ${PLOT_GC} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/plotGC.sh ${OUTPUTDIR}
echo bsub -W 89 -M 1 -w "done(${CORRECT_GC}_1[*]) && done(${CORRECT_GC}_2[*]) && done(${CORRECT_GC}_3[*]) && done(${CORRECT_GC}_4[*])" -J "${PLOT_GC}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/plotGC.sh ${OUTPUTDIR}
bsub -W 89 -M 1 -w "done(${CORRECT_GC}_1[*]) && done(${CORRECT_GC}_2[*]) && done(${CORRECT_GC}_3[*]) && done(${CORRECT_GC}_4[*])" -J "${PLOT_GC}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/plotGC.sh ${OUTPUTDIR}

##### END OF GC BIAS CORRECTION #####



##### CORRECTION OF FRAGMENT LENGTH BIAS #####

# count %duplicate for fragments with binned length
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=0.5G,mem_req=0.5G -hold_jid ${PROC_BAM} -N ${COUNT_DUP} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/count_dup.sh ${OUTPUTDIR}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=0.5G,mem_req=0.5G -hold_jid ${PROC_BAM} -N ${COUNT_DUP} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/count_dup.sh ${OUTPUTDIR}
echo bsub -W 89 -M 1 -w "done(${PROC_BAM}[*])" -J "${COUNT_DUP}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/count_dup.sh ${OUTPUTDIR}
bsub -W 89 -M 1 -w "done(${PROC_BAM}[*])" -J "${COUNT_DUP}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/count_dup.sh ${OUTPUTDIR}


# correct fragment length bias
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${CORRECT_BAF}_1,${CORRECT_BAF}_2,${CORRECT_BAF}_3,${CORRECT_BAF}_4,${CORRECT_GC}_1,${CORRECT_GC}_2,${CORRECT_GC}_3,${CORRECT_GC}_4,${COUNT_DUP} -N ${CORRECT_LENGTH} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_length.sh ${OUTPUTDIR} ${PROBE_BED}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${CORRECT_BAF}_1,${CORRECT_BAF}_2,${CORRECT_BAF}_3,${CORRECT_BAF}_4,${CORRECT_GC}_1,${CORRECT_GC}_2,${CORRECT_GC}_3,${CORRECT_GC}_4,${COUNT_DUP} -N ${CORRECT_LENGTH} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_length.sh ${OUTPUTDIR} ${PROBE_BED}
echo bsub -W 89 -M 1 -w "done(${CORRECT_BAF}_1[*]) && done(${CORRECT_BAF}_2[*]) && done(${CORRECT_BAF}_3[*]) && done(${CORRECT_BAF}_4[*]) && done(${CORRECT_GC}_1[*]) && done(${CORRECT_GC}_2[*]) && done(${CORRECT_GC}_3[*]) && done(${CORRECT_GC}_4[*]) && done(${COUNT_DUP}[*])" -J "${CORRECT_LENGTH}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_length.sh ${OUTPUTDIR} ${PROBE_BED}
bsub -W 89 -M 1 -w "done(${CORRECT_BAF}_1[*]) && done(${CORRECT_BAF}_2[*]) && done(${CORRECT_BAF}_3[*]) && done(${CORRECT_BAF}_4[*]) && done(${CORRECT_GC}_1[*]) && done(${CORRECT_GC}_2[*]) && done(${CORRECT_GC}_3[*]) && done(${CORRECT_GC}_4[*]) && done(${COUNT_DUP}[*])" -J "${CORRECT_LENGTH}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_length.sh ${OUTPUTDIR} ${PROBE_BED}

##### END OF FRAGMENT LENGTH BIAS CORRECTION #####



##### CORRECTION OF BIAS FROM WGA #####

if [ ${flg_repliG} = "TRUE" ]; then
	echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=2G,mem_req=2G -hold_jid ${CORRECT_LENGTH} -N ${CORRECT_WGA} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_wga.sh ${OUTPUTDIR} ${BAIT_GC}"
	qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=2G,mem_req=2G -hold_jid ${CORRECT_LENGTH} -N ${CORRECT_WGA} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_wga.sh ${OUTPUTDIR} ${BAIT_GC}
fi

##### END OF CORRECTION OF BIAS FROM WGA #####



##### CALCULATION OF MEAN DEPTH FOR EACH GENE #####

if [ ${MODE} == "Exome-seq" ]; then
	GENE_BED=${PROBE_DIR}/gene2exon.bed
	check_file_exists ${GENE_BED}

	echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=4G,mem_req=4G -hold_jid ${CORRECT_LENGTH},${CORRECT_WGA} -N ${GENE_DEPTH} ${LOGSTR} ${COMMAND_CNACS}/subscript_exome/gene_depth.sh ${OUTPUTDIR} ${GENE_BED}"
	qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=4G,mem_req=4G -hold_jid ${CORRECT_LENGTH},${CORRECT_WGA} -N ${GENE_DEPTH} ${LOGSTR} ${COMMAND_CNACS}/subscript_exome/gene_depth.sh ${OUTPUTDIR} ${GENE_BED}
fi

##### END OF MEAN DEPTH CALCULATION #####



##### MAIN #####

# filter out low quality probes
# make appropriate signals for control from control samples
# calculate signals for CBS
# perform CBS

# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=2G,mem_req=2G -hold_jid ${CORRECT_LENGTH},${CORRECT_WGA},${GENE_DEPTH} -N ${CNACS_MAIN} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/cnacs_main.sh ${OUTPUTDIR} ${BAF_INFO} ${BAF_FACTOR} ${BAF_FACTOR_ALL} ${ALL_DEPTH} ${REP_TIME}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=2G,mem_req=2G -hold_jid ${CORRECT_LENGTH},${CORRECT_WGA},${GENE_DEPTH} -N ${CNACS_MAIN} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/cnacs_main.sh ${OUTPUTDIR} ${BAF_INFO} ${BAF_FACTOR} ${BAF_FACTOR_ALL} ${ALL_DEPTH} ${REP_TIME}
# HOTFIX ONLY WORKS ON TARGETED-MAX
echo bsub -W 89 -M 2 -w "done(${CORRECT_LENGTH}[*])" -J "${CNACS_MAIN}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/cnacs_main.sh ${OUTPUTDIR} ${BAF_INFO} ${BAF_FACTOR} ${BAF_FACTOR_ALL} ${ALL_DEPTH} ${REP_TIME}
bsub -W 89 -M 2 -w "done(${CORRECT_LENGTH}[*])" -J "${CNACS_MAIN}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/cnacs_main.sh ${OUTPUTDIR} ${BAF_INFO} ${BAF_FACTOR} ${BAF_FACTOR_ALL} ${ALL_DEPTH} ${REP_TIME}


# draw a plot
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hold_jid ${CNACS_MAIN} -N ${PLOT} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/plot.sh ${OUTPUTDIR}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hold_jid ${CNACS_MAIN} -N ${PLOT} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/plot.sh ${OUTPUTDIR}
echo bsub -W 89 -M 2 -w "done(${CNACS_MAIN}[*])" -J "${PLOT}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/plot.sh ${OUTPUTDIR}
bsub -W 89 -M 2 -w "done(${CNACS_MAIN}[*])" -J "${PLOT}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/plot.sh ${OUTPUTDIR}

##### END OF MAIN #####



##### SUMMARIZATION #####

# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=0.5G,mem_req=0.5G -hold_jid ${CNACS_MAIN} -N ${CAT_RESULT} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/cat_result.sh ${OUTPUTDIR}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=0.5G,mem_req=0.5G -hold_jid ${CNACS_MAIN} -N ${CAT_RESULT} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/cat_result.sh ${OUTPUTDIR}
echo bsub -W 89 -M 1 -w "done(${CNACS_MAIN})" -J "${CAT_RESULT}" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/cat_result.sh ${OUTPUTDIR}
bsub -W 89 -M 1 -w "done(${CNACS_MAIN})" -J "${CAT_RESULT}" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/cat_result.sh ${OUTPUTDIR}

##### END OF SUMMARIZATION #####
