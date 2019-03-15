#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly GLOBAL_PROBE=$1
readonly TARGET=$2
readonly TAG=$3

source ${CONFIG}
source ${UTIL}

check_num_args $# 3

### Select SNPs in Tier 1-8 regions ###
for i in `seq 1 8`; do
echo -n "Processing "
eval echo '$TIER'${i}
eval ${BEDTOOLS_PATH}/intersectBed -a ${TARGET} -b '$TIER'${i} -wb | \
${BEDTOOLS_PATH}/intersectBed -a stdin -b ${GLOBAL_PROBE} -v | \
${PERL_PATH} ${COMMAND_CNACS}/subscript_design/cut_bed.pl ${i} \
> ${PROBEDIR}/${TAG}/tmp/tier${i}.bed
done


### Collect all the candidate SNPs ###
echo -n > ${PROBEDIR}/${TAG}/tmp/all.tmp.bed
for i in `seq 1 8`; do
echo "cat ${PROBEDIR}/${TAG}/tmp/tier${i}.bed >> ${PROBEDIR}/${TAG}/tmp/all.tmp.bed"
cat ${PROBEDIR}/${TAG}/tmp/tier${i}.bed >> ${PROBEDIR}/${TAG}/tmp/all.tmp.bed
done

# Sort
echo "${BEDTOOLS_PATH}/sortBed -i ${PROBEDIR}/${TAG}/tmp/all.tmp.bed \
> ${PROBEDIR}/${TAG}/${TAG}.all.bed"
${BEDTOOLS_PATH}/sortBed -i ${PROBEDIR}/${TAG}/tmp/all.tmp.bed \
> ${PROBEDIR}/${TAG}/${TAG}.all.bed


### Collect SNPs at each defined bin ###

for bin in 1000 3000 5000 10000 30000 50000 100000; do

echo "Collecting SNPs at ${bin}bp bins"
echo ""

echo "${PERL_PATH} ${COMMAND_CNACS}/subscript_design/split_bed.pl ${TARGET} ${bin} > ${PROBEDIR}/${TAG}/tmp/target.${bin}.bed"
${PERL_PATH} ${COMMAND_CNACS}/subscript_design/split_bed.pl ${TARGET} ${bin} > ${PROBEDIR}/${TAG}/tmp/target.${bin}.bed


for i in `seq 1 8`; do
echo -n "Processing "
eval echo '$TIER'${i}
cut -f 1-3 ${PROBEDIR}/${TAG}/tmp/target.${bin}.bed | \
eval ${BEDTOOLS_PATH}/intersectBed -a stdin -b '$TIER'${i} -wa -wb | \
${BEDTOOLS_PATH}/intersectBed -a stdin -b ${GLOBAL_PROBE} -v \
> ${PROBEDIR}/${TAG}/tmp/${bin}.tier${i}.bed
done

echo "Finalizing"
echo ""
${PERL_PATH} ${COMMAND_CNACS}/subscript_design/decide_snp.pl \
	${PROBEDIR}/${TAG}/tmp/target.${bin}.bed \
	${PROBEDIR}/${TAG}/tmp/${bin}.tier1.bed \
	${PROBEDIR}/${TAG}/tmp/${bin}.tier2.bed \
	${PROBEDIR}/${TAG}/tmp/${bin}.tier3.bed \
	${PROBEDIR}/${TAG}/tmp/${bin}.tier4.bed \
	${PROBEDIR}/${TAG}/tmp/${bin}.tier5.bed \
	${PROBEDIR}/${TAG}/tmp/${bin}.tier6.bed \
	${PROBEDIR}/${TAG}/tmp/${bin}.tier7.bed \
	${PROBEDIR}/${TAG}/tmp/${bin}.tier8.bed \
	${PROBEDIR}/${TAG}/${TAG}.${bin}.bed \
	${PROBEDIR}/${TAG}/tmp/${bin}.report.txt

done


### Make a summary ###

echo "Making a summary"
echo ""

${PERL_PATH} ${COMMAND_CNACS}/subscript_design/make_summary.pl \
	${PROBEDIR}/${TAG}/tmp/1000.report.txt \
	${PROBEDIR}/${TAG}/tmp/3000.report.txt \
	${PROBEDIR}/${TAG}/tmp/5000.report.txt \
	${PROBEDIR}/${TAG}/tmp/10000.report.txt \
	${PROBEDIR}/${TAG}/tmp/30000.report.txt \
	${PROBEDIR}/${TAG}/tmp/50000.report.txt \
	${PROBEDIR}/${TAG}/tmp/100000.report.txt \
	> ${PROBEDIR}/${TAG}/${TAG}.summary.txt

echo "rm -rf ${PROBEDIR}/${TAG}/tmp"
echo "rm -rf ${PROBEDIR}/${TAG}/tmp"

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
