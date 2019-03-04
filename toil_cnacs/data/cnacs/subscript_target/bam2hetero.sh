#!/bin/bash
#$ -S /bin/bash
#$ -cwd

readonly ORGDIR=$1
readonly SNP_BED=$2
readonly BAF_INFO=$3
readonly ID=$4
readonly BASE_QUALITY_THRESHOLD=$5
readonly GENREF=$6
readonly UPD_ERROR=$7
readonly COMMAND_CNACS=$8
readonly UTIL=$9

source ${UTIL}
check_num_args $# 9

check_mkdir ${ORGDIR}/${ID}/tmp

CMD="${SAMTOOLS_PATH}/samtools mpileup -BQ0 -d 10000000 -f ${GENREF} ${ORGDIR}/${ID}/tmp/filt.bam | \
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/pileup2base.pl ${BASE_QUALITY_THRESHOLD} ${SNP_BED} \
> ${ORGDIR}/${ID}/tmp/base_count.txt"
echo ${CMD}
eval ${CMD}

# calculate BAF and filter SNPs
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/filterBase.pl ${ORGDIR}/${ID}/tmp/base_count.txt ${UPD_ERROR} > ${ORGDIR}/${ID}/tmp/raw_baf.txt"
echo ${CMD}
eval ${CMD}

echo "rm ${ORGDIR}/${ID}/tmp/base_count.txt"
rm ${ORGDIR}/${ID}/tmp/base_count.txt

# adjust BAF
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/baf_adjust.pl ${ORGDIR}/${ID}/tmp/raw_baf.txt ${BAF_INFO} > ${ORGDIR}/${ID}/tmp/adjusted_baf.txt"
echo ${CMD}
eval ${CMD}


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
