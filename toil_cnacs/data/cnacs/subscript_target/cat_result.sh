#!/bin/bash
#$ -S /bin/bash
#$ -cwd

readonly OUTPUTDIR=$1

source ${CONFIG}
source ${UTIL}

TAG="${OUTPUTDIR##*/}"
echo ${TAG}

echo -n > ${OUTPUTDIR}/${TAG}_result.org.txt

echo "cat ${OUTPUTDIR}/*/*_result.txt | cut -f 1-4 >> ${OUTPUTDIR}/${TAG}_result.org.txt"
cat ${OUTPUTDIR}/*/*_result.txt | cut -f 1-4 >> ${OUTPUTDIR}/${TAG}_result.org.txt


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
