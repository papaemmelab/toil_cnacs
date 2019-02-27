#!/bin/csh

set thisdir=/home/ogawaprj/CopyNumberAnalysis/GISTIC

# --- SET UP ENVIRONMENT VARIABLES ---
echo --- setting up environment variables ---
# presumed location of MATLAB Component Runtime (MCR) v7.14
"# if the MCR is in a different location, edit the line below"
set mcr_root = $thisdir/MATLAB_Component_Runtime
setenv LD_LIBRARY_PATH $mcr_root/v714/runtime/glnxa64:$LD_LIBRARY_PATH
setenv LD_LIBRARY_PATH $mcr_root/v714/sys/os/glnxa64:$LD_LIBRARY_PATH
setenv LD_LIBRARY_PATH $mcr_root/v714/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:$LD_LIBRARY_PATH
setenv LD_LIBRARY_PATH $mcr_root/v714/sys/java/jre/glnxa64/jre/lib/amd64/server:$LD_LIBRARY_PATH
setenv LD_LIBRARY_PATH $mcr_root/v714/sys/java/jre/glnxa64/jre/lib/amd64:$LD_LIBRARY_PATH
setenv XAPPLRESDIR $mcr_root/v714/X11/app-defaults
# (these may be set permanently by copying the above lines into your login script)

# --- RUN GISTIC 2.0 ---
echo --- creating output directory ---
set basedir = $1
mkdir -p $basedir

echo --- running GISTIC ---
set segfile = $2
set markersfile = $3
set refgenefile = $thisdir/refgenefiles/hg19.mat
set cnvfile = $thisdir/CNVfile_Nsp_HMM_hg19.txt



$thisdir/gp_gistic2_from_seg -b $basedir -seg $segfile -mk $markersfile -refgene $refgenefile -cnv $cnvfile -genegistic 1 -smallmem 1 -broad 1 -rx 0 -brlen 0.5 -conf 0.90 -armpeel 1 -savegene 1 -gcm extreme
