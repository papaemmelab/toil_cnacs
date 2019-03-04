#!/bin/bash
#$ -S /bin/bash
#$ -cwd

readonly OUTPUTDIR=$1
readonly BAF_INFO=$2
readonly BAF_FACTOR=$3
readonly BAF_FACTOR_ALL=$4
readonly ALL_DEPTH=$5
readonly REP_TIME=$6
readonly ID=$7
readonly CBS_ALPHA_BAF=$8
readonly CBS_ALPHA_DEP=$9
readonly PAR_BED=${10}
readonly COMMAND_CNACS=${11}
readonly UTIL=${12}

source ${UTIL}

check_num_args $# 12


# filter out low-quality probes
# make an input file for CBS (BAF)
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/make_input.pl ${OUTPUTDIR}/${ID}/tmp/combined_gene_normdep.txt ${OUTPUTDIR}/${ID}/tmp/adjusted_baf.txt ${BAF_INFO} ${BAF_FACTOR} ${BAF_FACTOR_ALL} ${ALL_DEPTH} ${OUTPUTDIR}/${ID}/tmp/depth_input.txt ${OUTPUTDIR}/${ID}/tmp/baf_input.csv ${OUTPUTDIR}/${ID}/tmp/baf_all.txt"
echo ${CMD}
eval ${CMD}
check_error $?


# circular binary segmentation (BAF)
CMD="${R_PATH} --vanilla --slave --args ${ID} ${OUTPUTDIR}/${ID}/tmp/baf_input.csv ${OUTPUTDIR}/${ID}/tmp/segment_baf.txt ${CBS_ALPHA_BAF} < ${COMMAND_CNACS}/subscript_target/cbs.R"
echo ${CMD}
eval ${CMD}
check_error $?

CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/seg2bed.pl ${OUTPUTDIR}/${ID}/tmp/segment_baf.txt \
> ${OUTPUTDIR}/${ID}/tmp/segment_baf.bed"
echo ${CMD}
eval ${CMD}
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
	CMD="${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/depth_input.txt ${OUTPUTDIR}/${ID}/tmp/current_depth.txt ${ALL_DEPTH} ${ID} ${OUTPUTDIR}/${ID}/tmp/signal_tmp.txt ${OUTPUTDIR}/${ID}/tmp/signal_dip.txt ${OUTPUTDIR}/${ID}/tmp/control_depth.tmp.txt ${OUTPUTDIR}/${ID}/tmp/control_info.tmp.txt < ${COMMAND_CNACS}/subscript_target/make_control.R"
	echo ${CMD}
	eval ${CMD}
	check_error $?


	# correct differences in replication timing
	CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/reptime2depth.pl ${OUTPUTDIR}/${ID}/tmp/signal_tmp.txt ${REP_TIME} \
	> ${OUTPUTDIR}/${ID}/tmp/reptime2depth.txt"
	echo ${CMD}
	eval ${CMD}

	CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/reptime2depth.pl ${OUTPUTDIR}/${ID}/tmp/signal_dip.txt ${REP_TIME} \
	> ${OUTPUTDIR}/${ID}/tmp/reptime2depth_dip.txt"
	echo ${CMD}
	eval ${CMD}

	CMD="${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/reptime2depth.txt ${OUTPUTDIR}/${ID}/tmp/reptime2depth_dip.txt ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.txt ${OUTPUTDIR}/${ID}/tmp/reptime2depth.pdf < ${COMMAND_CNACS}/subscript_target/adjust_reptime.R"
	echo ${CMD}
	eval ${CMD}


	# make an input file for CBS (depth)
	CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/make_input_CBS.pl ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.txt \
	> ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.csv"
	echo ${CMD}
	eval ${CMD}


	# circular binary segmentation (depth)
	CMD="${R_PATH} --vanilla --slave --args ${ID} ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.csv ${OUTPUTDIR}/${ID}/tmp/segment_depth.txt ${CBS_ALPHA_DEP} < ${COMMAND_CNACS}/subscript_target/cbs.R"
	echo ${CMD}
	eval ${CMD}
	check_error $?

	CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/seg2bed.pl ${OUTPUTDIR}/${ID}/tmp/segment_depth.txt \
	> ${OUTPUTDIR}/${ID}/tmp/segment_depth.bed
	check_error $?"
	echo ${CMD}
	eval ${CMD}
	check_error $?


	# merge signals of depth and BAF
	CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/merge_signals.pl ${OUTPUTDIR}/${ID}/tmp/signal_adjusted.csv ${OUTPUTDIR}/${ID}/tmp/baf_input.csv \
	> ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt"
	echo ${CMD}
	eval ${CMD}


	# define diploid regions
	if [ ${LOOP} -eq 1 ]; then
		export R_LIBS=${R_LIBS_PATH}

		CMD="${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${OUTPUTDIR}/${ID}/${ID}_diploid_region.txt < ${COMMAND_CNACS}/subscript_target/define_diploid.R"
		echo ${CMD}
		eval ${CMD}
		check_error $?
	fi


	# merge temporary segments
	echo "cat ${OUTPUTDIR}/${ID}/tmp/segment_depth.bed >> ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed"
	cat ${OUTPUTDIR}/${ID}/tmp/segment_depth.bed >> ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed

	CMD="${BEDTOOLS_PATH}/sortBed -i ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed | \
	${BEDTOOLS_PATH}/mergeBed -i stdin | \
	${BEDTOOLS_PATH}/intersectBed -a stdin -b ${OUTPUTDIR}/${ID}/tmp/segment_tmp.bed -wa -wb | sort -u | \
	${PERL_PATH} ${COMMAND_CNACS}/subscript_target/merge_seg.pl ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt \
	> ${OUTPUTDIR}/${ID}/tmp/segment_tmp_pre.txt"
	echo ${CMD}
	eval ${CMD}

	CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/proc_end.pl ${OUTPUTDIR}/${ID}/tmp/segment_tmp_pre.txt ${ID} \
	> ${OUTPUTDIR}/${ID}/tmp/segment_pre.txt"
	echo ${CMD}
	eval ${CMD}


	# filter candidate CNAs
	CMD="${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/segment_pre.txt ${OUTPUTDIR}/${ID}/tmp/segment_tmp.txt < ${COMMAND_CNACS}/subscript_target/filt_cna.R"
	echo ${CMD}
	eval ${CMD}


	# depth normalization using depth of diploid regions
	CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/norm_depth_cnacs.pl ${OUTPUTDIR}/${ID}/${ID}_diploid_region.txt ${OUTPUTDIR}/${ID}/tmp/segment_tmp.txt ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${PAR_BED} ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt ${OUTPUTDIR}/${ID}/tmp/proc_signal.txt ${OUTPUTDIR}/${ID}/tmp/summary.txt"
	echo ${CMD}
	eval ${CMD}
	check_error $?

	# difference from a former loop
	if [ ${LOOP} -gt 1 ]; then
		echo -n > ${OUTPUTDIR}/${ID}/tmp/diff.txt

		CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/compare_result.pl ${OUTPUTDIR}/${ID}/tmp/result_pre.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt >> ${OUTPUTDIR}/${ID}/tmp/diff.txt"
		echo ${CMD}
		eval ${CMD}
		check_error $?
	fi

	# make an input file for a next step
	CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/make_input_recursion.pl ${OUTPUTDIR}/${ID}/tmp/depth_input.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt\
	> ${OUTPUTDIR}/${ID}/tmp/current_depth.txt"
	echo ${CMD}
	eval ${CMD}
	check_error $?
done


# final output
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/filt_cna.pl ${OUTPUTDIR}/${ID}/tmp/proc_signal.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp.txt \
> ${OUTPUTDIR}/${ID}/tmp/result_tmp2.txt"
echo ${CMD}
eval ${CMD}

# additional CNAs
CMD="${R_PATH} --vanilla --slave --args ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${OUTPUTDIR}/${ID}/tmp/cna_region.txt ${OUTPUTDIR}/${ID}/${ID}_scatter_plot.pdf < ${COMMAND_CNACS}/subscript_target/add_cna.R"
echo ${CMD}
eval ${CMD}
check_error $?

CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/add_cna.pl ${OUTPUTDIR}/${ID}/tmp/result_tmp2.txt ${OUTPUTDIR}/${ID}/tmp/cna_region.txt ${OUTPUTDIR}/${ID}/tmp/merged_signal.txt ${ID}\
> ${OUTPUTDIR}/${ID}/tmp/result_tmp3.txt"
echo ${CMD}
eval ${CMD}


# additional UPDs
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/add_upd.pl ${OUTPUTDIR}/${ID}/tmp/baf_all.txt ${OUTPUTDIR}/${ID}/tmp/proc_signal.txt ${OUTPUTDIR}/${ID}/tmp/result_tmp3.txt ${ID} > ${OUTPUTDIR}/${ID}/${ID}_result.txt"
echo ${CMD}
eval ${CMD}


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
