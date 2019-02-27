#!/bin/bash
#$ -S /bin/bash
#$ -cwd

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

# output files
readonly BAF_INFO_FILT=${ORGDIR}/stats/baf_stats.txt

ALL_DEPTH=${ORGDIR}/stats/all_depth.txt
cp ${ORGDIR}/stats/header.txt ${ALL_DEPTH}

GENE_REGION=${ORGDIR}/stats/gene_info.txt

# thresholds
readonly BAF_MEAN_LOWER=`head -n 1 ${THRESHOLD} | tail -n 1 | cut -f 2`
readonly BAF_MEAN_UPPER=`head -n 2 ${THRESHOLD} | tail -n 1 | cut -f 2`
readonly BAF_COEFVAR_UPPER=`head -n 3 ${THRESHOLD} | tail -n 1 | cut -f 2`
readonly DEPTH_MEAN_LOWER=`head -n 4 ${THRESHOLD} | tail -n 1 | cut -f 2`
readonly DEPTH_MEAN_UPPER=`head -n 5 ${THRESHOLD} | tail -n 1 | cut -f 2`
readonly DEPTH_COEFVAR_UPPER=`head -n 6 ${THRESHOLD} | tail -n 1 | cut -f 2`

CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/ref_install.pl \
	${PROBE_BED} \
	${BAF_INFO} \
	${DEPTH_INFO} \
	${BAF_INFO_FILT} \
	${ALL_DEPTH} \
	${GENE_REGION} \
	${BAF_MEAN_LOWER} \
	${BAF_MEAN_UPPER} \
	${BAF_COEFVAR_UPPER} \
	${DEPTH_MEAN_LOWER} \
	${DEPTH_MEAN_UPPER} \
	${DEPTH_COEFVAR_UPPER}"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/ref_install.pl \
	${PROBE_BED} \
	${BAF_INFO} \
	${DEPTH_INFO} \
	${BAF_INFO_FILT} \
	${ALL_DEPTH} \
	${GENE_REGION} \
	${BAF_MEAN_LOWER} \
	${BAF_MEAN_UPPER} \
	${BAF_COEFVAR_UPPER} \
	${DEPTH_MEAN_LOWER} \
	${DEPTH_MEAN_UPPER} \
	${DEPTH_COEFVAR_UPPER}


### plot distribution of probes ###
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


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
