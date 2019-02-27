#!/bin/bash
#$ -S /bin/bash
#$ -cwd

readonly OUTPUTDIR=$1
readonly ID=$2
readonly ALL_DEPTH=$3
readonly REP_TIME=$4
readonly REGION=$5
readonly PLOIDY=$6
readonly BAF_INFO=$7
readonly BAF_FACTOR=$8
readonly BAF_FACTOR_ALL=$9

source ${CONFIG}
source ${UTIL}

check_num_args $# 9

export R_LIBS=${R_LIBS_PATH}:${R_LIBS}

readonly STATSDIR=`dirname ${ALL_DEPTH}`
readonly GENE_INFO=${STATSDIR}/gene_info.txt

echo "rm ${OUTPUTDIR}/${ID}/${ID}_diploid_region.txt"
rm ${OUTPUTDIR}/${ID}/${ID}_diploid_region.txt


# filter out low-quality probes
# make an input file for CBS (BAF)
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/make_input.pl ${OUTPUTDIR}/${ID}/tmp/combined_normdep.txt ${OUTPUTDIR}/${ID}/tmp/adjusted_baf.txt ${BAF_INFO} ${BAF_FACTOR} ${BAF_FACTOR_ALL} ${ALL_DEPTH} ${OUTPUTDIR}/${ID}/tmp/depth_input.txt ${OUTPUTDIR}/${ID}/tmp/baf_input.csv ${OUTPUTDIR}/${ID}/tmp/baf_all.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/make_input.pl ${OUTPUTDIR}/${ID}/tmp/combined_normdep.txt ${OUTPUTDIR}/${ID}/tmp/adjusted_baf.txt ${BAF_INFO} ${BAF_FACTOR} ${BAF_FACTOR_ALL} ${ALL_DEPTH} ${OUTPUTDIR}/${ID}/tmp/depth_input.txt ${OUTPUTDIR}/${ID}/tmp/baf_input.csv ${OUTPUTDIR}/${ID}/tmp/baf_all.txt
check_error $?


# circular binary segmentation (BAF)
echo "${R_PATH} --vanilla --slave --args ${ID} ${OUTPUTDIR}/${ID}/tmp/baf_input.csv ${OUTPUTDIR}/${ID}/tmp/segment_baf.txt ${CBS_ALPHA_BAF} < ${COMMAND_CNACS}/subscript_target/cbs.R"
${R_PATH} --vanilla --slave --args ${ID} ${OUTPUTDIR}/${ID}/tmp/baf_input.csv ${OUTPUTDIR}/${ID}/tmp/segment_baf.txt ${CBS_ALPHA_BAF} < ${COMMAND_CNACS}/subscript_target/cbs.R
check_error $?

echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/seg2bed.pl ${OUTPUTDIR}/${ID}/tmp/segment_baf.txt > ${OUTPUTDIR}/${ID}/tmp/segment_baf.bed"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/seg2bed.pl ${OUTPUTDIR}/${ID}/tmp/segment_baf.txt > ${OUTPUTDIR}/${ID}/tmp/segment_baf.bed
check_error $?


### start a recursive process ###

# count
LOOP=0

# differences from a former loop
echo -n > ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt
echo start! > ${OUTPUTDIR}/${ID}/tmp/diff.txt

echo "cp ${OUTPUTDIR}/${ID}/tmp/depth_input.txt ${OUTPUTDIR}/${ID}/tmp/current_depth.txt"
cp ${OUTPUTDIR}/${ID}/tmp/depth_input.txt ${OUTPUTDIR}/${ID}/tmp/current_depth.txt

while [ ${LOOP} -lt 10 -a -s ${OUTPUTDIR}/${ID}/tmp/diff.txt ]
do
	LOOP=`expr ${LOOP} + 1`
	echo Start Loop ${LOOP}
	
	echo "cp ${OUTPUTDIR}/${ID}/tmp/segment_baf.bed ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed"
	cp ${OUTPUTDIR}/${ID}/tmp/segment_baf.bed ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed
	
	echo "mv ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt ${OUTPUTDIR}/${ID}/tmp/result_pre.txt"
	mv ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt ${OUTPUTDIR}/${ID}/tmp/result_pre.txt
	
	# make temporary control signals from control samples
	# calculate temporary signals for CBS
	echo "${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/depth_input.txt ${OUTPUTDIR}/${ID}/tmp/current_depth.txt ${ALL_DEPTH} ${ID} ${OUTPUTDIR}/${ID}/tmp/signal_tmp.txt ${OUTPUTDIR}/${ID}/tmp/signal_dip.txt ${OUTPUTDIR}/${ID}/tmp/control_depth.tmp.txt ${OUTPUTDIR}/${ID}/tmp/control_info.tmp.txt < ${COMMAND_CNACS}/subscript_target/make_control.R"
	${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/depth_input.txt ${OUTPUTDIR}/${ID}/tmp/current_depth.txt ${ALL_DEPTH} ${ID} ${OUTPUTDIR}/${ID}/tmp/signal_tmp.txt ${OUTPUTDIR}/${ID}/tmp/signal_dip.txt ${OUTPUTDIR}/${ID}/tmp/control_depth.tmp.txt ${OUTPUTDIR}/${ID}/tmp/control_info.tmp.txt < ${COMMAND_CNACS}/subscript_target/make_control.R
	check_error $?
	
	
	# correct differences in replication timing
	echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/reptime2depth.pl ${OUTPUTDIR}/${ID}/tmp/signal_tmp.txt ${REP_TIME} \
	> ${OUTPUTDIR}/${ID}/tmp/reptime2depth.txt"
	${PERL_PATH} ${COMMAND_CNACS}/subscript_target/reptime2depth.pl ${OUTPUTDIR}/${ID}/tmp/signal_tmp.txt ${REP_TIME} \
	> ${OUTPUTDIR}/${ID}/tmp/reptime2depth.txt
	
	echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/reptime2depth.pl ${OUTPUTDIR}/${ID}/tmp/signal_dip.txt ${REP_TIME} \
	> ${OUTPUTDIR}/${ID}/tmp/reptime2depth_dip.txt"
	${PERL_PATH} ${COMMAND_CNACS}/subscript_target/reptime2depth.pl ${OUTPUTDIR}/${ID}/tmp/signal_dip.txt ${REP_TIME} \
	> ${OUTPUTDIR}/${ID}/tmp/reptime2depth_dip.txt
	
	echo "${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/reptime2depth.txt ${OUTPUTDIR}/${ID}/tmp/reptime2depth_dip.txt ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.txt ${OUTPUTDIR}/${ID}/tmp/reptime2depth.pdf < ${COMMAND_CNACS}/subscript_target/adjust_reptime.R"
	${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/reptime2depth.txt ${OUTPUTDIR}/${ID}/tmp/reptime2depth_dip.txt ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.txt ${OUTPUTDIR}/${ID}/tmp/reptime2depth.pdf < ${COMMAND_CNACS}/subscript_target/adjust_reptime.R
	
	
	# make an input file for CBS (depth)
	echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/make_input_CBS.pl ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.txt \
	> ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.csv"
	${PERL_PATH} ${COMMAND_CNACS}/subscript_target/make_input_CBS.pl ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.txt \
	> ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.csv
	
	
	# circular binary segmentation (depth)
	echo "${R_PATH} --vanilla --slave --args ${ID} ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.csv ${OUTPUTDIR}/${ID}/tmp/segment_depth.txt ${CBS_ALPHA_DEP} < ${COMMAND_CNACS}/subscript_target/cbs.R"
	${R_PATH} --vanilla --slave --args ${ID} ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.csv ${OUTPUTDIR}/${ID}/tmp/segment_depth.txt ${CBS_ALPHA_DEP} < ${COMMAND_CNACS}/subscript_target/cbs.R
	check_error $?
	
	echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/seg2bed.pl ${OUTPUTDIR}/${ID}/tmp/segment_depth.txt \
	> ${OUTPUTDIR}/${ID}/tmp/segment_depth.bed
	check_error $?"
	${PERL_PATH} ${COMMAND_CNACS}/subscript_target/seg2bed.pl ${OUTPUTDIR}/${ID}/tmp/segment_depth.txt \
	> ${OUTPUTDIR}/${ID}/tmp/segment_depth.bed
	check_error $?
	
	
	# merge signals of depth and BAF
	echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/merge_signals.pl ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.csv ${OUTPUTDIR}/${ID}/tmp/baf_input.csv \
	> ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt"
	${PERL_PATH} ${COMMAND_CNACS}/subscript_target/merge_signals.pl ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.csv ${OUTPUTDIR}/${ID}/tmp/baf_input.csv \
	> ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt
	
	
	# merge temporary segments
	echo "cat ${OUTPUTDIR}/${ID}/tmp/segment_depth.bed >> ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed"
	cat ${OUTPUTDIR}/${ID}/tmp/segment_depth.bed >> ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed
	
	echo "${BEDTOOLS_PATH}/sortBed -i ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed | \
	${BEDTOOLS_PATH}/mergeBed -i stdin | \
	${BEDTOOLS_PATH}/intersectBed -a stdin -b ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed -wa -wb | sort -u | \
	${PERL_PATH} ${COMMAND_CNACS}/subscript_target/merge_seg.pl ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt \
	> ${OUTPUTDIR}/${ID}/tmp/segment_tmp_pre.txt"
	${BEDTOOLS_PATH}/sortBed -i ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed | \
	${BEDTOOLS_PATH}/mergeBed -i stdin | \
	${BEDTOOLS_PATH}/intersectBed -a stdin -b ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed -wa -wb | sort -u | \
	${PERL_PATH} ${COMMAND_CNACS}/subscript_target/merge_seg.pl ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt \
	> ${OUTPUTDIR}/${ID}/tmp/segment_tmp_pre.txt
	
	echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/proc_end.pl ${OUTPUTDIR}/${ID}/tmp/segment_tmp_pre.txt ${ID} \
	> ${OUTPUTDIR}/${ID}/tmp/segment_pre.txt"
	${PERL_PATH} ${COMMAND_CNACS}/subscript_target/proc_end.pl ${OUTPUTDIR}/${ID}/tmp/segment_tmp_pre.txt ${ID} \
	> ${OUTPUTDIR}/${ID}/tmp/segment_pre.txt
	
	
	# filter candidate CNAs
	echo "${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/segment_pre.txt ${OUTPUTDIR}/${ID}/tmp/segment_tmp.txt < ${COMMAND_CNACS}/subscript_target/filt_cna.R"
	${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/segment_pre.txt ${OUTPUTDIR}/${ID}/tmp/segment_tmp.txt < ${COMMAND_CNACS}/subscript_target/filt_cna.R
	
	
	# depth normalization using depth of diploid regions
	echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/norm_depth_adjust.pl ${OUTPUTDIR}/${ID}/tmp/segment_tmp.txt ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${GENE_INFO} ${PAR_BED} ${REGION} ${PLOIDY} ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt ${OUTPUTDIR}/${ID}/tmp/proc_signal.txt ${OUTPUTDIR}/${ID}/tmp/summary.txt"
	${PERL_PATH} ${COMMAND_CNACS}/subscript_target/norm_depth_adjust.pl ${OUTPUTDIR}/${ID}/tmp/segment_tmp.txt ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${GENE_INFO} ${PAR_BED} ${REGION} ${PLOIDY} ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt ${OUTPUTDIR}/${ID}/tmp/proc_signal.txt ${OUTPUTDIR}/${ID}/tmp/summary.txt
	check_error $?
	
	# difference from a former loop
	if [ ${LOOP} -gt 1 ]; then
		echo -n > ${OUTPUTDIR}/${ID}/tmp/diff.txt
		
		echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/compare_result.pl ${OUTPUTDIR}/${ID}/tmp/result_pre.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt >> ${OUTPUTDIR}/${ID}/tmp/diff.txt"
		${PERL_PATH} ${COMMAND_CNACS}/subscript_target/compare_result.pl ${OUTPUTDIR}/${ID}/tmp/result_pre.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt >> ${OUTPUTDIR}/${ID}/tmp/diff.txt
		check_error $?
	fi
	
	# make an input file for a next step
	echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/make_input_recursion.pl ${OUTPUTDIR}/${ID}/tmp/depth_input.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt\
	> ${OUTPUTDIR}/${ID}/tmp/current_depth.txt"
	${PERL_PATH} ${COMMAND_CNACS}/subscript_target/make_input_recursion.pl ${OUTPUTDIR}/${ID}/tmp/depth_input.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt\
	> ${OUTPUTDIR}/${ID}/tmp/current_depth.txt
	check_error $?
done


# additional CNAs
echo "${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${OUTPUTDIR}/${ID}/tmp/cna_region.txt ${OUTPUTDIR}/${ID}/${ID}_scatter_plot.pdf < ${COMMAND_CNACS}/subscript_target/add_cna.R"
${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${OUTPUTDIR}/${ID}/tmp/cna_region.txt ${OUTPUTDIR}/${ID}/${ID}_scatter_plot.pdf  < ${COMMAND_CNACS}/subscript_target/add_cna.R
check_error $?

echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/add_cna.pl ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt ${OUTPUTDIR}/${ID}/tmp/cna_region.txt ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${ID}\
> ${OUTPUTDIR}/${ID}/tmp/result_tmp2.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/add_cna.pl ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt ${OUTPUTDIR}/${ID}/tmp/cna_region.txt ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${ID}\
> ${OUTPUTDIR}/${ID}/tmp/result_tmp2.txt


# additional UPDs
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/add_upd.pl ${OUTPUTDIR}/${ID}/tmp/baf_all.txt ${OUTPUTDIR}/${ID}/tmp/proc_signal.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp2.txt ${ID} ${GENE_INFO} > ${OUTPUTDIR}/${ID}/tmp/result_tmp3.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/add_upd.pl ${OUTPUTDIR}/${ID}/tmp/baf_all.txt ${OUTPUTDIR}/${ID}/tmp/proc_signal.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp2.txt ${ID} ${GENE_INFO} > ${OUTPUTDIR}/${ID}/tmp/result_tmp3.txt


# final output
echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_target/filt_cna.pl ${OUTPUTDIR}/${ID}/tmp/proc_signal.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp3.txt \
> ${OUTPUTDIR}/${ID}/${ID}_result.txt"
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/filt_cna.pl ${OUTPUTDIR}/${ID}/tmp/proc_signal.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp3.txt \
> ${OUTPUTDIR}/${ID}/${ID}_result.txt


echo "rm ${OUTPUTDIR}/${ID}/tmp/depth_input.txt"
echo "rm ${OUTPUTDIR}/${ID}/tmp/baf_input.csv"
echo "rm ${OUTPUTDIR}/${ID}/tmp/signal_tmp.txt"
echo "rm ${OUTPUTDIR}/${ID}/tmp/signal_dip.txt"
echo "rm ${OUTPUTDIR}/${ID}/tmp/current_depth.txt"
echo "rm ${OUTPUTDIR}/${ID}/tmp/control_depth.tmp.txt"
echo "rm ${OUTPUTDIR}/${ID}/tmp/reptime2depth.txt"
echo "rm ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.txt"
echo "rm ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.csv"
echo "rm ${OUTPUTDIR}/${ID}/tmp/diff.txt"
rm ${OUTPUTDIR}/${ID}/tmp/depth_input.txt
rm ${OUTPUTDIR}/${ID}/tmp/baf_input.csv
rm ${OUTPUTDIR}/${ID}/tmp/signal_tmp.txt
rm ${OUTPUTDIR}/${ID}/tmp/signal_dip.txt
rm ${OUTPUTDIR}/${ID}/tmp/current_depth.txt
rm ${OUTPUTDIR}/${ID}/tmp/control_depth.tmp.txt
rm ${OUTPUTDIR}/${ID}/tmp/reptime2depth.txt
rm ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.txt
rm ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.csv
rm ${OUTPUTDIR}/${ID}/tmp/diff.txt

echo "mv ${OUTPUTDIR}/${ID}/tmp/proc_signal.txt ${OUTPUTDIR}/${ID}/${ID}_signal.txt"
echo "mv ${OUTPUTDIR}/${ID}/tmp/control_info.tmp.txt ${OUTPUTDIR}/${ID}/${ID}_control.txt"
echo "mv ${OUTPUTDIR}/${ID}/tmp/summary.txt ${OUTPUTDIR}/${ID}/${ID}_summary.txt"
echo "mv ${OUTPUTDIR}/${ID}/tmp/reptime2depth.pdf ${OUTPUTDIR}/${ID}/${ID}_reptime2depth.pdf"
mv ${OUTPUTDIR}/${ID}/tmp/proc_signal.txt ${OUTPUTDIR}/${ID}/${ID}_signal.txt
mv ${OUTPUTDIR}/${ID}/tmp/control_info.tmp.txt ${OUTPUTDIR}/${ID}/${ID}_control.txt
mv ${OUTPUTDIR}/${ID}/tmp/summary.txt ${OUTPUTDIR}/${ID}/${ID}_summary.txt
mv ${OUTPUTDIR}/${ID}/tmp/reptime2depth.pdf ${OUTPUTDIR}/${ID}/${ID}_reptime2depth.pdf

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
