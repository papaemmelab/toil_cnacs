"""toil_cnacs jobs."""

from os.path import join
import os

from toil_container import ContainerJob

from toil_cnacs import constants
from toil_cnacs import utils


class BaseJob(ContainerJob):

    """Job base class used to share variables and methods across steps."""

    def __init__(self, options, cnacs_kwargs=None, *args, **kwargs):
        """
        Use this base class to share variables across pipelines steps.
        Arguments:
            options (object): an argparse name space object.
            args (list): arguments to be passed to toil.job.Job.
            kwargs (dict): key word arguments to be passed to toil.job.Job.
        """
        utils.make_dir(options.outdir)
        self.__dict__.update(cnacs_kwargs or {})
        self.options = options
        self.repli_time = join(self.options.db_dir, "repli_timing", "hg19.interval.bed")
        self.all_bed = join(self.options.db_dir, "all.bed")
        self.par_bed = join(self.options.db_dir, "pseudo_auto", "PAR_hg19.bed")
        self.cytoband_dir = join(self.options.db_dir, "cytoBand")
        super(BaseJob, self).__init__(options=options, *args, **kwargs)


class BaitSize(BaseJob):
    # get bait size to determine processing mode
    def run(self, fileStore):
        self.call(
            [
                "perl",
                join(constants.CNACS_DIR, "subscript_design", "check_bed.pl"),
                self.options.probe_bed,
                str(self.options.autosome),
            ]
        )
        bait_size = self.call(
            [
                "perl",
                join(constants.CNACS_DIR, "subscript_target", "bait_size.pl"),
                self.options.probe_bed,
                str(self.options.mode_thres),
            ],
            check_output=True,
        )

        if int(bait_size) < self.options.mode_thres:
            mode = "Targeted-seq"
            subscript = "subscript_target"
        else:
            mode = "Exome-seq"
            subscript = "subscript_exome"
            if not self.options.gene2exon:
                raise Exception("Exome detected but no gene2exon.bed provided!")

        fileStore.logToMaster("%s mode will be applied" % mode)
        return {"mode": mode, "subscript": subscript}


class Preprocess(BaseJob):
    # select SNPs in the target regions
    # obtain sequences of target regions (including flanking regions)
    # obtain information on replication timing
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_target", "preprocess.sh"),
                self.options.outdir,
                self.options.probe_bed,
                self.all_bed,
                str(self.options.max_frag_length),
                self.options.fasta,
                self.repli_time,
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class ProcBam(BaseJob):
    # process BAM files
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, self.mode["subscript"], "proc_bam.sh"),
                self.options.outdir,
                self.options.probe_bed,
                self.sample[0],
                os.path.basename(self.sample[0]).replace(".bam", ""),
                str(self.options.max_frag_length),
                str(self.options.mapping_quality_threshold),
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class DivideBed(BaseJob):
    # divide BED files according to fragments' length
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_target", "divide_bed.sh"),
                self.options.outdir,
                self.options.probe_bed,
                self.sample[0],
                os.path.basename(self.sample[0]).replace(".bam", ""),
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class BaitGCWGA(BaseJob):
    # calculate GC content for correction of bias from whole-genome amplification
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_target", "bait_gc_wga.sh"),
                self.options.outdir,
                self.options.probe_bed,
                str(self.options.wga_length),
                self.options.fasta,
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class CountDup(BaseJob):
    # count %duplicate for fragments with binned length
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_target", "count_dup.sh"),
                self.options.outdir,
                self.sample[0],
                os.path.basename(self.sample[0]).replace(".bam", ""),
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class Bam2HeteroRef(BaseJob):
    # SNP typing
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_target", "bam2hetero_ref.sh"),
                self.options.outdir,
                self.options.probe_bed,
                self.sample[0],
                os.path.basename(self.sample[0]).replace(".bam", ""),
                str(self.options.base_quality_threshold),
                self.options.fasta,
                str(self.options.upd_error),
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class CatBafInfo(BaseJob):
    # summarize information on BAF
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_target", "cat_baf_info.sh"),
                self.options.outdir,
                self.options.probe_bed,
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class Probe2Scale(BaseJob):
    # decide scaling factors for SNP-overlapping fragments
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_target", "probe2scale.sh"),
                self.options.outdir,
                join(self.options.outdir, "stats", "baf_factor.bed"),
                self.sample[0],
                os.path.basename(self.sample[0]).replace(".bam", ""),
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class CorrectBafRef(BaseJob):
    # compensate for low capture efficiency of fragments containing minor alleles
    # by fragement quartile
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_target", "correct_baf_ref.sh"),
                self.options.outdir,
                self.options.probe_bed,
                str(self.quartile),
                self.sample[0],
                os.path.basename(self.sample[0]).replace(".bam", ""),
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class CorrectGCRef(BaseJob):
    # GC bias correction
    # by fragment quartile
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, self.mode["subscript"], "correct_gc_ref.sh"),
                self.options.outdir,
                self.options.probe_bed,
                self.sample[1],
                str(self.quartile),
                os.path.basename(self.sample[0]).replace(".bam", ""),
                str(self.options.max_frag_length),
                self.par_bed,
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class PlotGC(BaseJob):
    # plot gc
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_target", "plotGC.sh"),
                self.options.outdir,
                os.path.basename(self.sample[0]).replace(".bam", ""),
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class CorrectLengthRef(BaseJob):
    # correct fragment length bias
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_target", "correct_length_ref.sh"),
                self.options.outdir,
                os.path.basename(self.sample[0]).replace(".bam", ""),
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class CorrectWGARef(BaseJob):
    # correct wga bias
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_target", "correct_wga_ref.sh"),
                self.options.outdir,
                join(self.options.outdir, "bait_gc.txt"),
                os.path.basename(self.sample[0]).replace(".bam", ""),
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class GeneDepth(BaseJob):
    # depths for each gene
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, "subscript_exome", "gene_depth.sh"),
                self.options.outdir,
                self.options.gene2exon,
                os.path.basename(self.sample[0]).replace(".bam", ""),
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class CatDepth(BaseJob):
    # summarize depth info
    def run(self, fileStore):
        self.call(
            [
                join(constants.CNACS_DIR, self.mode["subscript"], "cat_depth.sh"),
                self.options.outdir,
                self.options.probe_bed,
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )


class RefInstall(BaseJob):
    # install reference pool
    def run(self, fileStore):
        threshold = join(self.options.outdir, "stats", "threshold.txt")
        if not os.path.isfile(threshold):
            raise Exception("Output directory does not contain /stats/threshold.txt")
        self.call(
            [
                join(
                    constants.CNACS_DIR, self.mode["subscript"], "ref_install_main.sh"
                ),
                self.options.outdir,
                self.options.probe_bed,
                threshold,
                self.cytoband_dir,
                constants.CNACS_DIR,
                constants.UTIL,
            ]
        )

