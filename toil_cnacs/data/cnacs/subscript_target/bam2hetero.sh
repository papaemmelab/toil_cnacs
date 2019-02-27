#!/bin/bash
#$ -S /bin/bash
#$ -cwd

readonly ORGDIR=$1
readonly SNP_BED=$2
readonly BAF_INFO=$3

source ${CONFIG}
source ${UTIL}

check_num_args $# 3

# readonly SEQBAM=`head -n ${SGE_TASK_ID} ${ORGDIR}/bam_list.txt | tail -n 1`
readonly SEQBAM=`head -n ${LSB_JOBINDEX} ${ORGDIR}/bam_list.txt | tail -n 1`
TMP_ID="${SEQBAM##*/}"
ID=`echo ${TMP_ID} | sed -e "s/\.bam//"`

check_mkdir ${ORGDIR}/${ID}/tmp


echo "${SAMTOOLS_PATH}/samtools mpileup -BQ0 -d 10000000 -f ${GENREF} ${ORGDIR}/${ID}/tmp/filt.bam | \
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/pileup2base.pl ${BASE_QUALITY_THRESHOLD} ${SNP_BED} \
> ${ORGDIR}/${ID}/tmp/base_count.txt"
${SAMTOOLS_PATH}/samtools mpileup -BQ0 -d 10000000 -f ${GENREF} ${ORGDIR}/${ID}/tmp/filt.bam | \
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/pileup2base.pl ${BASE_QUALITY_THRESHOLD} ${SNP_BED} \
> ${ORGDIR}/${ID}/tmp/base_count.txt


# calculate BAF and filter SNPs
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/filterBase.pl ${ORGDIR}/${ID}/tmp/base_count.txt ${UPD_ERROR} > ${ORGDIR}/${ID}/tmp/raw_baf.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/filterBase.pl ${ORGDIR}/${ID}/tmp/base_count.txt ${UPD_ERROR} > ${ORGDIR}/${ID}/tmp/raw_baf.txt
check_error $?

echo "rm ${ORGDIR}/${ID}/tmp/base_count.txt"
rm ${ORGDIR}/${ID}/tmp/base_count.txt


# adjust BAF
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/baf_adjust.pl ${ORGDIR}/${ID}/tmp/raw_baf.txt ${BAF_INFO} > ${ORGDIR}/${ID}/tmp/adjusted_baf.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/baf_adjust.pl ${ORGDIR}/${ID}/tmp/raw_baf.txt ${BAF_INFO} > ${ORGDIR}/${ID}/tmp/adjusted_baf.txt


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
