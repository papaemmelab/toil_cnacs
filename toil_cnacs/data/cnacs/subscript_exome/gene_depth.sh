#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly ORGDIR=$1
readonly GENE_BED=$2
readonly ID=$3
readonly COMMAND_CNACS=$4
readonly UTIL=$5

source ${UTIL}

check_num_args $# 5

# calculate mean signals for each gene
for LENG_NUM in `seq 1 4`
do
	CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/gene_depth.pl ${ORGDIR}/${ID}/tmp/predicted_depth_leng${LENG_NUM}.txt ${ORGDIR}/${ID}/tmp/actual_depth_leng${LENG_NUM}.txt ${GENE_BED} \
	> ${ORGDIR}/${ID}/tmp/depth_ratio_gene_leng${LENG_NUM}.txt"
	echo ${CMD}
	eval ${CMD}
done

# combine depths
CMD="${R_PATH} --vanilla --slave --args ${ORGDIR}/${ID}/tmp/depth_ratio_gene_leng1.txt ${ORGDIR}/${ID}/tmp/depth_ratio_gene_leng2.txt ${ORGDIR}/${ID}/tmp/depth_ratio_gene_leng3.txt ${ORGDIR}/${ID}/tmp/depth_ratio_gene_leng4.txt ${ORGDIR}/${ID}/tmp/length_bias.txt ${ORGDIR}/${ID}/tmp/combined_gene_depth.csv \
< ${COMMAND_CNACS}/subscript_exome/combine_rate.R"
echo ${CMD}
eval ${CMD}

CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/combine_depth.pl ${ORGDIR}/${ID}/tmp/combined_gene_depth.csv ${ORGDIR}/${ID}/tmp/depth_ratio_gene_leng1.txt \
> ${ORGDIR}/${ID}/tmp/combined_gene_depth.txt"
echo ${CMD}
eval ${CMD}

echo "rm ${ORGDIR}/${ID}/tmp/combined_gene_depth.csv"
rm ${ORGDIR}/${ID}/tmp/combined_gene_depth.csv

# log_transformation
# normalization
CMD="${PERL_PATH} ${COMMAND_CNACS}/subscript_exome/norm_depth.pl ${ORGDIR}/${ID}/tmp/combined_gene_depth.txt \
> ${ORGDIR}/${ID}/tmp/combined_gene_normdep.txt"
echo ${CMD}
eval ${CMD}


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
