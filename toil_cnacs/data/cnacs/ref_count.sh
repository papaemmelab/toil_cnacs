#! /bin/bash
#$ -S /bin/bash
#$ -cwd

write_usage() {
	echo ""
	echo "Usage: `basename $0` [options] <tag> <BED file of probes> [<config>]"
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
PROBE_BED=$2
CONFIG=$3

DIR=`dirname ${0}`

# confirm right number of arguments
if [ $# -le 1 -o $# -ge 4 ]; then
	echo "wrong number of arguments"
	write_usage
	exit 1
fi

if [ $# -eq 2 ]; then
	CONFIG=${DIR}/../conf/hg19.env
fi

if [ $# -eq 3 ]; then
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

PROBE_DIR=`dirname ${PROBE_BED}`
PROBE_DIR=`echo $(cd ${PROBE_DIR} && pwd)`
PROBE_FILE="${PROBE_BED##*/}"
PROBE_BED=${PROBE_DIR}/${PROBE_FILE}


# import configuration files
source ${CONFIG}
source ${UTIL}
echo "${CNACSDIR} is CNACSDIR"


# check input files
check_file_exists ${PROBE_BED}

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

# check an input directory
readonly ORGDIR=${CNACSDIR}/control/${TAG}
echo "${ORGDIR} is ORGDIR"

if [ ! -e  ${ORGDIR} ]; then
	echo "${ORGDIR} does not exist"
	write_usage
	exit 1
fi

# check a file with information on sex of the samples
readonly SEX_INFO=`find ${ORGDIR} -name "sex_info.txt"`
check_file_exists ${SEX_INFO}


# make a log directory
readonly CURLOGDIR=${LOGDIR}/control/${TAG}
check_mkdir ${CURLOGDIR}
readonly LOGSTR=-e\ ${CURLOGDIR}\ -o\ ${CURLOGDIR}


# collect information on sample names
find ${ORGDIR} -maxdepth 2 -name "*.bam" > ${ORGDIR}/bam_list.txt
FILECOUNT=`wc -l ${ORGDIR}/bam_list.txt | cut -d " " -f 1`

for i in `seq 1 ${FILECOUNT}`
do
	SEQBAM=`head -n ${i} ${ORGDIR}/bam_list.txt | tail -n 1`
	TMP_ID="${SEQBAM##*/}"
	ID=`echo ${TMP_ID} | sed -e "s/\.bam//"`
	ID2=`echo ${ID} | sed -e "s/s_//"`

	SEX_STATUS_ALL=`${PERL_PATH} ${COMMAND_CNACS}/subscript_target/check_sex.pl ${SEX_INFO} ${ID2}`
	SEX_STATUS=`echo ${SEX_STATUS_ALL} | cut -d ":" -f 1`
	if [ ! ${SEX_STATUS} = "Done" ]; then
		echo ${SEX_STATUS_ALL}
		exit 1
	fi
done


### define job names
# PREPROCESSING
readonly PREPROCESS=preprocess.ref.${TAG}
readonly PROC_BAM=proc_bam.ref.${TAG}
readonly DIVIDE_BED=divide_bed.ref.${TAG}
readonly BAIT_GC_WGA=bait_gc_wga.ref.${TAG}

# PROCESSING INFORMATION ON BAF
readonly BAM2HETERO=bam2hetero.ref.${TAG}
readonly CAT_BAF_INFO=cat_baf_info.ref.${TAG}

# COMPENSATION FOR LOW CAPTURE EFFICIENCY DUE TO MINOR ALLELE
readonly PROBE2SCALE=probe2scale.ref.${TAG}
readonly CORRECT_BAF=correct_baf.ref.${TAG}

# GC BIAS CORRECTION
readonly CORRECT_GC=correct_gc.ref.${TAG}
readonly PLOT_GC=plot_gc.ref.${TAG}

# CORRECTION OF FRAGMENT LENGTH BIAS
readonly COUNT_DUP=count_dup.ref.${TAG}
readonly CORRECT_LENGTH=correct_length.ref.${TAG}

# CORRECTION OF BIAS FROM WGA
readonly CORRECT_WGA=correct_wga.ref.${TAG}

# CALCULATION OF MEAN DEPTH FOR EACH GENE
readonly GENE_DEPTH=gene_depth.ref.${TAG}

# PROCESSING INFORMATION ON DEPTH
readonly CAT_DEPTH=cat_depth.ref.${TAG}


##### PREPROCESSING #####

# select SNPs in the target regions
# obtain sequences of target regions (including flanking regions)
# obtain information on replication timing
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=6G,mem_req=6G -N ${PREPROCESS} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/preprocess.sh ${ORGDIR} ${PROBE_BED}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=6G,mem_req=6G -N ${PREPROCESS} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/preprocess.sh ${ORGDIR} ${PROBE_BED}
echo bsub -env 'CONFIG=${CONFIG}' -W 89 -M 6 -J ${PREPROCESS} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/preprocess.sh ${ORGDIR} ${PROBE_BED}
bsub -W 89 -M 6 -J ${PREPROCESS} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/preprocess.sh ${ORGDIR} ${PROBE_BED}

# process BAM files
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=8G,mem_req=8G -N ${PROC_BAM} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/proc_bam.sh ${ORGDIR} ${PROBE_BED}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=8G,mem_req=8G -N ${PROC_BAM} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/proc_bam.sh ${ORGDIR} ${PROBE_BED}
echo bsub -W 89 -M 8 -J "${PROC_BAM}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/proc_bam.sh ${ORGDIR} ${PROBE_BED}
bsub -W 89 -M 8 -J "${PROC_BAM}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/proc_bam.sh ${ORGDIR} ${PROBE_BED}

# divide BED files according to fragments' length
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PROC_BAM} -N ${DIVIDE_BED} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/divide_bed.sh ${ORGDIR}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PROC_BAM} -N ${DIVIDE_BED} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/divide_bed.sh ${ORGDIR}
echo bsub -M 1 -w "done(${PROC_BAM}[*])" -J "${DIVIDE_BED}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/divide_bed.sh ${ORGDIR}
bsub -W 89 -M 1 -w "done(${PROC_BAM}[*])" -J "${DIVIDE_BED}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/divide_bed.sh ${ORGDIR}


# calculate GC content for correction of bias from whole-genome amplification
if [ ${flg_repliG} = "TRUE" ]; then
	echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=6G,mem_req=6G -N ${BAIT_GC_WGA} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/bait_gc_wga.sh ${ORGDIR} ${PROBE_BED}"
	qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=6G,mem_req=6G -N ${BAIT_GC_WGA} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/bait_gc_wga.sh ${ORGDIR} ${PROBE_BED}
fi

##### END OF PREPROCESSING #####



##### PROCESSING INFORMATION ON BAF #####

# SNP typing
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PREPROCESS},${PROC_BAM} -N ${BAM2HETERO} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/bam2hetero_ref.sh ${ORGDIR}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PREPROCESS},${PROC_BAM} -N ${BAM2HETERO} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/bam2hetero_ref.sh ${ORGDIR}
echo bsub -M 1 -w "done(${PREPROCESS}) && done(${PROC_BAM}[*])" -J "${BAM2HETERO}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/bam2hetero_ref.sh ${ORGDIR}
bsub -W 89 -M 1 -w "done(${PREPROCESS}) && done(${PROC_BAM}[*])" -J "${BAM2HETERO}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/bam2hetero_ref.sh ${ORGDIR}


# summarize information on BAF
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=0.5G,mem_req=0.5G -hold_jid ${BAM2HETERO} -N ${CAT_BAF_INFO} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/cat_baf_info.sh ${ORGDIR} ${PROBE_BED}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=0.5G,mem_req=0.5G -hold_jid ${BAM2HETERO} -N ${CAT_BAF_INFO} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/cat_baf_info.sh ${ORGDIR} ${PROBE_BED}
echo bsub -M 1 -w "done(${BAM2HETERO})" -J "${CAT_BAF_INFO}" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/cat_baf_info.sh ${ORGDIR} ${PROBE_BED}
bsub -W 89 -M 1 -w "done(${BAM2HETERO})" -J "${CAT_BAF_INFO}" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/cat_baf_info.sh ${ORGDIR} ${PROBE_BED}

##### END OF PROCESSING INFORMATION ON BAF #####



##### COMPENSATION FOR LOW CAPTURE EFFICIENCY DUE TO MINOR ALLELES  #####

readonly BAF_FACTOR=${ORGDIR}/stats/baf_factor.bed

# decide scaling factors for SNP-overlapping fragments
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${CAT_BAF_INFO} -N ${PROBE2SCALE} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/probe2scale.sh ${ORGDIR} ${BAF_FACTOR}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${CAT_BAF_INFO} -N ${PROBE2SCALE} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/probe2scale.sh ${ORGDIR} ${BAF_FACTOR}
echo bsub -M 1 -w "done(${CAT_BAF_INFO})" -J "${PROBE2SCALE}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/probe2scale.sh ${ORGDIR} ${BAF_FACTOR}
bsub -W 89 -M 1 -w "done(${CAT_BAF_INFO})" -J "${PROBE2SCALE}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/probe2scale.sh ${ORGDIR} ${BAF_FACTOR}


# compensate for low capture efficiency of fragments containing minor alleles
for i in `seq 1 4`
do
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PROBE2SCALE} -N ${CORRECT_BAF}_${i} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_baf_ref.sh ${ORGDIR} ${PROBE_BED} ${i}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${PROBE2SCALE} -N ${CORRECT_BAF}_${i} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_baf_ref.sh ${ORGDIR} ${PROBE_BED} ${i}
echo bsub -M 1 -w "done(${PROBE2SCALE}[*])" -J "${CORRECT_BAF}_${i}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_baf_ref.sh ${ORGDIR} ${PROBE_BED} ${i}
bsub -W 89 -M 1 -w "done(${PROBE2SCALE}[*])" -J "${CORRECT_BAF}_${i}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_baf_ref.sh ${ORGDIR} ${PROBE_BED} ${i}
done

##### END OF COMPENSATION FOR LOW CAPTURE EFFICIENCY DUE TO MINOR ALLELES  #####



##### GC BIAS CORRECTION #####

for i in `seq 1 4`
do
	# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=5.3G,mem_req=5.3G -hold_jid ${PREPROCESS},${DIVIDE_BED} -N ${CORRECT_GC}_${i} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/correct_gc_ref.sh ${ORGDIR} ${PROBE_BED} ${SEX_INFO} ${i}"
	# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=5.3G,mem_req=5.3G -hold_jid ${PREPROCESS},${DIVIDE_BED} -N ${CORRECT_GC}_${i} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/correct_gc_ref.sh ${ORGDIR} ${PROBE_BED} ${SEX_INFO} ${i}
	echo bsub -M 6 -w "done(${PREPROCESS}) && done(${DIVIDE_BED}[*])" -J "${CORRECT_GC}_${i}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/correct_gc_ref.sh ${ORGDIR} ${PROBE_BED} ${SEX_INFO} ${i}
	bsub -W 89 -M 6 -w "done(${PREPROCESS}) && done(${DIVIDE_BED}[*])" -J "${CORRECT_GC}_${i}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/correct_gc_ref.sh ${ORGDIR} ${PROBE_BED} ${SEX_INFO} ${i}
done


# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${CORRECT_GC}_1,${CORRECT_GC}_2,${CORRECT_GC}_3,${CORRECT_GC}_4 -N ${PLOT_GC} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/plotGC.sh ${ORGDIR}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${CORRECT_GC}_1,${CORRECT_GC}_2,${CORRECT_GC}_3,${CORRECT_GC}_4 -N ${PLOT_GC} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/plotGC.sh ${ORGDIR}
echo bsub -W 89 -M 1 -w "done(${CORRECT_GC}_1[*]) && done(${CORRECT_GC}_2[*]) && done(${CORRECT_GC}_3[*]) && done(${CORRECT_GC}_4[*])" -J "${PLOT_GC}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/plotGC.sh ${ORGDIR}
bsub -W 89 -M 1 -w "done(${CORRECT_GC}_1[*]) && done(${CORRECT_GC}_2[*]) && done(${CORRECT_GC}_3[*]) && done(${CORRECT_GC}_4[*])" -J "${PLOT_GC}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/plotGC.sh ${ORGDIR}

##### END OF GC BIAS CORRECTION #####



##### CORRECTION OF FRAGMENT LENGTH BIAS #####

# count %duplicate for fragments with binned length
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=0.5G,mem_req=0.5G -hold_jid ${PROC_BAM} -N ${COUNT_DUP} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/count_dup.sh ${ORGDIR}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=0.5G,mem_req=0.5G -hold_jid ${PROC_BAM} -N ${COUNT_DUP} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/count_dup.sh ${ORGDIR}
echo bsub -M 1 -w "done(${PROC_BAM}[*])" -J "${COUNT_DUP}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/count_dup.sh ${ORGDIR}
bsub -We 89 -M 1 -w "done(${PROC_BAM}[*])" -J "${COUNT_DUP}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/count_dup.sh ${ORGDIR}


# correct fragment length bias
# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${CORRECT_BAF}_1,${CORRECT_BAF}_2,${CORRECT_BAF}_3,${CORRECT_BAF}_4,${CORRECT_GC}_1,${CORRECT_GC}_2,${CORRECT_GC}_3,${CORRECT_GC}_4,${COUNT_DUP} -N ${CORRECT_LENGTH} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_length_ref.sh ${ORGDIR} ${PROBE_BED}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=1G,mem_req=1G -hold_jid ${CORRECT_BAF}_1,${CORRECT_BAF}_2,${CORRECT_BAF}_3,${CORRECT_BAF}_4,${CORRECT_GC}_1,${CORRECT_GC}_2,${CORRECT_GC}_3,${CORRECT_GC}_4,${COUNT_DUP} -N ${CORRECT_LENGTH} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_length_ref.sh ${ORGDIR} ${PROBE_BED}
echo bsub -M 1 -w "done(${CORRECT_BAF}_1[*]) && done(${CORRECT_BAF}_2[*]) && done(${CORRECT_BAF}_3[*]) && done(${CORRECT_BAF}_4[*]) && done(${CORRECT_GC}_1[*]) && done(${CORRECT_GC}_2[*]) && done(${CORRECT_GC}_3[*]) && done(${CORRECT_GC}_4[*]) && done(${COUNT_DUP}[*])" -J "${CORRECT_LENGTH}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_length_ref.sh ${ORGDIR} ${PROBE_BED}
bsub -W 89 -M 1 -w "done(${CORRECT_BAF}_1[*]) && done(${CORRECT_BAF}_2[*]) && done(${CORRECT_BAF}_3[*]) && done(${CORRECT_BAF}_4[*]) && done(${CORRECT_GC}_1[*]) && done(${CORRECT_GC}_2[*]) && done(${CORRECT_GC}_3[*]) && done(${CORRECT_GC}_4[*]) && done(${COUNT_DUP}[*])" -J "${CORRECT_LENGTH}[1-${FILECOUNT}]" ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_length_ref.sh ${ORGDIR} ${PROBE_BED}

##### END OF FRAGMENT LENGTH BIAS CORRECTION #####



##### CORRECTION OF BIAS FROM WGA #####

if [ ${flg_repliG} = "TRUE" ]; then
	echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=2G,mem_req=2G -hold_jid ${CORRECT_LENGTH},${BAIT_GC_WGA} -N ${CORRECT_WGA} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_wga_ref.sh ${ORGDIR} ${ORGDIR}/bait_gc.txt"
	qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=2G,mem_req=2G -hold_jid ${CORRECT_LENGTH},${BAIT_GC_WGA} -N ${CORRECT_WGA} ${LOGSTR} ${COMMAND_CNACS}/subscript_target/correct_wga_ref.sh ${ORGDIR} ${ORGDIR}/bait_gc.txt
fi

##### END OF CORRECTION OF BIAS FROM WGA #####



##### CALCULATION OF MEAN DEPTH FOR EACH GENE #####

if [ ${MODE} == "Exome-seq" ]; then
	readonly GENE_BED=${PROBE_DIR}/gene2exon.bed
	check_file_exists ${GENE_BED}

	echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=4G,mem_req=4G -hold_jid ${CORRECT_LENGTH},${CORRECT_WGA} -N ${GENE_DEPTH} ${LOGSTR} ${COMMAND_CNACS}/subscript_exome/gene_depth.sh ${ORGDIR} ${GENE_BED}"
	qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -t 1-${FILECOUNT}:1 -hard -l s_vmem=4G,mem_req=4G -hold_jid ${CORRECT_LENGTH},${CORRECT_WGA} -N ${GENE_DEPTH} ${LOGSTR} ${COMMAND_CNACS}/subscript_exome/gene_depth.sh ${ORGDIR} ${GENE_BED}
fi

##### END OF MEAN DEPTH CALCULATION #####



##### PROCESSING INFORMATION ON DEPTH #####

if [ ${MODE} == "Targeted-seq" ]; then
	MEMORY=1
else
	MEMORY=6
fi

# echo "qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=${MEMORY}G,mem_req=${MEMORY}G -hold_jid ${CORRECT_LENGTH},${CORRECT_WGA},${GENE_DEPTH} -N ${CAT_DEPTH} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/cat_depth.sh ${ORGDIR} ${PROBE_BED}"
# qsub -soft -l ljob,lmem -v CONFIG=${CONFIG} -hard -l s_vmem=${MEMORY}G,mem_req=${MEMORY}G -hold_jid ${CORRECT_LENGTH},${CORRECT_WGA},${GENE_DEPTH} -N ${CAT_DEPTH} ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/cat_depth.sh ${ORGDIR} ${PROBE_BED}
# HOT FIX WILL ONLY WORK FOR TARGETED -MAX
echo bsub -M ${MEMORY} -w "done(${CORRECT_LENGTH})" -J "${CAT_DEPTH}" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/cat_depth.sh ${ORGDIR} ${PROBE_BED}
bsub -W 89 -M ${MEMORY} -w "done(${CORRECT_LENGTH})" -J "${CAT_DEPTH}" ${LOGSTR} ${COMMAND_CNACS}/${SUBSCRIPT}/cat_depth.sh ${ORGDIR} ${PROBE_BED}

##### END OF PROCESSING INFORMATION ON DEPTH #####
