#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly ORGDIR=$1
readonly PROBE_BED=$2
readonly COMMAND_CNACS=$3
readonly UTIL=$4

source ${UTIL}

check_num_args $# 4
check_mkdir ${ORGDIR}/stats

files=()
while read file
do
	files+=("$file")
done < <(find ${ORGDIR} -name "combined_normdep.txt")

dup_files=()
while read dup_file
do
	dup_files+=("$dup_file")
done < <(find ${ORGDIR} -name "duplicate_stats.txt")

bias_files=()
while read bias_file
do
	bias_files+=("$bias_file")
done < <(find ${ORGDIR} -name "length_bias.txt")


CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/make_case_header.pl "${files[@]}" > ${ORGDIR}/stats/header.txt"
echo ${CMD}
eval ${CMD}

CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/cat_depth.pl ${PROBE_BED} "${files[@]}" | \
${PERL_PATH} ${COMMAND_CNACS}/subscript_target/snp_statistics2.pl \
> ${ORGDIR}/stats/depth_summary.txt"
echo ${CMD}
eval ${CMD}
check_error $?


# Mean of depth
CMD="cut -f 4 ${ORGDIR}/stats/depth_summary.txt | grep -v NA | perl -nle 'print \$_ if ( \$_ < 10 )' > ${ORGDIR}/stats/depth_mean.txt"
echo ${CMD}
eval ${CMD}

CMD="${R_PATH} --vanilla --slave --args ${ORGDIR}/stats/depth_mean.txt ${ORGDIR}/stats/depth_mean.pdf Mean_of_normalized_depth < ${COMMAND_CNACS}/subscript_target/hist.R"
echo ${CMD}
eval ${CMD}

echo "rm ${ORGDIR}/stats/depth_mean.txt"
rm ${ORGDIR}/stats/depth_mean.txt


# Coefficient of variation of depth
CMD="cut -f 5 ${ORGDIR}/stats/depth_summary.txt | grep -v NA | perl -nle 'print \$_ if ( \$_ < 1 )' > ${ORGDIR}/stats/depth_coefvar.txt"
echo ${CMD}
eval ${CMD}

CMD="${R_PATH} --vanilla --slave --args ${ORGDIR}/stats/depth_coefvar.txt ${ORGDIR}/stats/depth_coefvar.pdf CoefVar_of_normalized_depth < ${COMMAND_CNACS}/subscript_target/hist.R"
echo ${CMD}
eval ${CMD}

echo "rm ${ORGDIR}/stats/depth_coefvar.txt"
rm ${ORGDIR}/stats/depth_coefvar.txt


CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/cat_amp.pl "${dup_files[@]}" \
> ${ORGDIR}/stats/duplicate_stats.csv"
echo ${CMD}
eval ${CMD}
check_error $?

CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_target/cat_amp.pl "${bias_files[@]}" \
> ${ORGDIR}/stats/length_bias.csv"
echo ${CMD}
eval ${CMD}
check_error $?

CMD="${R_PATH} --vanilla --slave --args ${ORGDIR}/stats/duplicate_stats.csv ${ORGDIR}/stats/duplicate_stats.pdf \
< ${COMMAND_CNACS}/subscript_target/barplot.R"
echo ${CMD}
eval ${CMD}

CMD="${R_PATH} --vanilla --slave --args ${ORGDIR}/stats/length_bias.csv ${ORGDIR}/stats/length_bias.pdf \
< ${COMMAND_CNACS}/subscript_target/barplot.R"
echo ${CMD}
eval ${CMD}


echo "rm ${ORGDIR}/stats/duplicate_stats.csv"
echo "rm ${ORGDIR}/stats/length_bias.csv"
rm ${ORGDIR}/stats/duplicate_stats.csv
rm ${ORGDIR}/stats/length_bias.csv

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
