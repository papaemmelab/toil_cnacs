#!/bin/bash
#$ -S /bin/bash
#$ -cwd
set -eu
readonly OUTPUTDIR=$1

TAG="${OUTPUTDIR##*/}"
echo ${TAG}

echo -n > ${OUTPUTDIR}/${TAG}_result.org.txt

echo "cat ${OUTPUTDIR}/*/*_result.txt | cut -f 1-4 >> ${OUTPUTDIR}/${TAG}_result.org.txt"
cat ${OUTPUTDIR}/*/*_result.txt | cut -f 1-4 >> ${OUTPUTDIR}/${TAG}_result.org.txt


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
