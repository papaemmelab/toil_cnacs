#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly ORGDIR=$1
readonly PROBE_BED=$2
readonly THRESHOLD=$3
readonly CYTOBAND_DIR=$4
readonly COMMAND_CNACS=$5
readonly UTIL=$6

source ${UTIL}

check_num_args $# 6


# input files
readonly BAF_INFO=${ORGDIR}/stats/baf_stats.org.txt
readonly DEPTH_INFO=${ORGDIR}/stats/depth_summary.txt
readonly CYTOBAND=${CYTOBAND_DIR}/cytoBand_rgb2.csv
readonly CENTROMERE=${CYTOBAND_DIR}/centromere_pos.txt

# Output files
readonly BAF_INFO_FILT=${ORGDIR}/stats/baf_stats.txt
readonly ALL_DEPTH=${ORGDIR}/stats/all_depth.txt
cp ${ORGDIR}/stats/header.txt ${ALL_DEPTH}

# thresholds
readonly BAF_MEAN_LOWER=`head -n 1 ${THRESHOLD} | tail -n 1 | cut -f 2`
readonly BAF_MEAN_UPPER=`head -n 2 ${THRESHOLD} | tail -n 1 | cut -f 2`
readonly BAF_COEFVAR_UPPER=`head -n 3 ${THRESHOLD} | tail -n 1 | cut -f 2`
readonly DEPTH_MEAN_LOWER=`head -n 4 ${THRESHOLD} | tail -n 1 | cut -f 2`
readonly DEPTH_MEAN_UPPER=`head -n 5 ${THRESHOLD} | tail -n 1 | cut -f 2`
readonly DEPTH_COEFVAR_UPPER=`head -n 6 ${THRESHOLD} | tail -n 1 | cut -f 2`


### Processing mean signals for each gene ###

CMD="cat ${DEPTH_INFO} | ${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/filt_info.pl | \
${BEDTOOLS_PATH}/intersectBed -a stdin -b ${TARGET_BED} -wa \
> ${DEPTH_INFO}.targeted"
echo ${CMD}
eval ${CMD}

CMD="cat ${DEPTH_INFO} | ${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/filt_info.pl | \
${BEDTOOLS_PATH}/intersectBed -a stdin -b ${TARGET_BED} -v -wa \
> ${DEPTH_INFO}.non_targeted"
echo ${CMD}
eval ${CMD}

CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/ref_install_gene.pl \
	${DEPTH_INFO}.targeted \
	${DEPTH_INFO}.non_targeted \
	${ALL_DEPTH} \
	${DEPTH_MEAN_LOWER} \
	${DEPTH_MEAN_UPPER} \
	${DEPTH_COEFVAR_UPPER}"
echo ${CMD}
eval ${CMD}

echo "rm ${DEPTH_INFO}.targeted"
echo "rm ${DEPTH_INFO}.non_targeted"
rm ${DEPTH_INFO}.targeted
rm ${DEPTH_INFO}.non_targeted

### End of processing mean signals ###


### Processing BAFs ###

CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/ref_install_snp.pl \
	${BAF_INFO} \
	${BAF_INFO_FILT} \
	${BAF_MEAN_LOWER} \
	${BAF_MEAN_UPPER} \
	${BAF_COEFVAR_UPPER}"
echo ${CMD}
eval ${CMD}

### End of processing BAFs ###



### Plot distribution of probes ###

CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/dist_input_all.pl ${ALL_DEPTH} ${BAF_INFO_FILT} > ${ORGDIR}/stats/bait_dist/bait_dist.tmp1.txt"
echo ${CMD}
eval ${CMD}

CMD="${R_PATH} --vanilla --slave --args ${ORGDIR}/stats/bait_dist/bait_dist.tmp1.txt ${CENTROMERE} ${ORGDIR}/stats/bait_dist/dist_all.pdf < ${COMMAND_CNACS}/subscript_target/plot_bait_all.R"
echo ${CMD}
eval ${CMD}

echo "rm ${ORGDIR}/stats/bait_dist/bait_dist.tmp1.txt"
rm ${ORGDIR}/stats/bait_dist/bait_dist.tmp1.txt


for i in `seq 1 23`
do
	CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/dist_input_chr.pl ${ALL_DEPTH} ${BAF_INFO_FILT} ${i} > ${ORGDIR}/stats/bait_dist/bait_dist.tmp2.txt"
	echo ${CMD}
	eval ${CMD}

	CMD="${R_PATH} --vanilla --slave --args ${ORGDIR}/stats/bait_dist/bait_dist.tmp2.txt ${CYTOBAND} ${ORGDIR}/stats/bait_dist/dist_chr${i}.pdf ${i} < ${COMMAND_CNACS}/subscript_target/plot_bait_chr.R"
	echo ${CMD}
	eval ${CMD}

	echo "rm ${ORGDIR}/stats/bait_dist/bait_dist.tmp2.txt"
	rm ${ORGDIR}/stats/bait_dist/bait_dist.tmp2.txt
done

### End of plot ###


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
