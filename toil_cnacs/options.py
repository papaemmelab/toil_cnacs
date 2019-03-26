"""toil_cnacs options."""

from os.path import join
import os
import subprocess

from toil_container import ContainerArgumentParser
import click

from toil_cnacs import __version__
from toil_cnacs import constants
from toil_cnacs import exceptions
from toil_cnacs import validators


def get_parser(step):
    """Get pipeline configuration using toil's."""
    parser = ContainerArgumentParser(version=__version__)

    descriptions = {
        "generate_pool": constants.GENERATE_POOL_DOCS,
        "finalise_pool": constants.FINALISE_POOL_DOCS,
        "run": constants.RUN_DOCS,
    }

    # add description to parser
    parser.description = descriptions[step]
    parser.description += ". See `" + step + " configuration` for options."

    # we need to add a group of arguments specific to the pipeline
    settings = parser.add_argument_group(step + " configuration")

    settings.add_argument(
        "--outdir",
        help="Output directory",
        required=True,
        type=click.Path(dir_okay=True, writable=True, resolve_path=True),
    )

    settings.add_argument(
        "--db_dir",
        help="cnacs database dir",
        type=click.Path(exists=True, dir_okay=True, readable=True, resolve_path=True),
    )

    settings.add_argument(
        "--fasta",
        help="reference fasta (hg19)",
        required=True,
        type=click.Path(exists=True, file_okay=True, readable=True, resolve_path=True),
    )

    if step == "generate_pool":
        settings.add_argument(
            "--probe_bed",
            help="capture bed file",
            required=True,
            type=click.Path(file_okay=True, readable=True, resolve_path=True),
        )

        settings.add_argument(
            "--pool_samp",
            help="Normal Sample for Pool bam and sex, space seperated: --pool_samp bam sex"
            "; Multiple accepted; Use between 5 and 10 samples",
            nargs=2,
            action="append",
            required=True,
            metavar=("bam", "sex"),
        )

    if step == "run":
        settings.add_argument(
            "--pool_dir",
            help="pool dir for panel from generate_pool",
            required=True,
            type=click.Path(
                exists=True, dir_okay=True, readable=True, resolve_path=True
            ),
        )

        settings.add_argument(
            "--samp", help="Tumor bam; Multiple accepted", action="append"
        )

        settings.add_argument(
            "--samp_file",
            help="List of Tumor bams; One per line",
            type=click.Path(
                exists=True, file_okay=True, readable=True, resolve_path=True
            ),
        )

        settings.add_argument(
            "--cbs_alpha_dep", help="?", required=False, default=0.0005, type=float
        )

        settings.add_argument(
            "--cbs_alpha_baf", help="?", required=False, default=0.05, type=float
        )

    settings.add_argument(
        "--gene2exon",
        help="?bed of exons? (for exomes)",
        required=False,
        type=click.Path(file_okay=True, readable=True, resolve_path=True),
    )

    settings.add_argument(
        "--autosome", help="number of autosomes", required=False, default=22, type=int
    )

    settings.add_argument(
        "--mode_thres",
        help="region size cutoff in KB for processing as exome",
        required=False,
        default=3000,
        type=int,
    )

    settings.add_argument(
        "--flg_repliG", help="perform wga correction", action="store_true"
    )

    settings.add_argument(
        "--max_frag_length",
        "-mfl",
        dest="max_frag_length",
        help="maximum fragment length to use",
        required=False,
        default=1000,
        type=int,
    )

    settings.add_argument(
        "--wga_length",
        "-wgal",
        dest="wga_length",
        help="? wga correction length",
        required=False,
        default=12500,
        type=int,
    )

    settings.add_argument(
        "--mapping_quality_threshold",
        "-mqt",
        dest="mapping_quality_threshold",
        help="maximum fragment length to use",
        required=False,
        default=30,
        type=int,
    )

    settings.add_argument(
        "--base_quality_threshold",
        "-bqt",
        dest="base_quality_threshold",
        help="maximum fragment length to use",
        required=False,
        default=15,
        type=int,
    )

    settings.add_argument(
        "--upd_error", help="?", required=False, default=0.01, type=float
    )

    return parser


def process_parsed_options(options, step):
    """Perform validations and add post parsing attributes to `options`."""
    if options.writeLogs is not None:
        subprocess.check_call(["mkdir", "-p", options.writeLogs])

    if not (options.docker or options.singularity):
        if not options.db_dir:
            raise exceptions.MissingDataError(
                "Database dir must be provided with --db_dir if not run in the container"
            )
    else:
        options.db_dir = "/ref/db"

    if vars(options).get("pool_samp"):
        valid_samples = [
            [
                click.Path(file_okay=True, readable=True, resolve_path=True)(pair[0]),
                click.Choice(["M", "F"])(pair[1]),
            ]
            for pair in options.pool_samp
        ]
        options.pool_samp = valid_samples

    if step == "finalise_pool":
        options.probe_bed = join(options.pool_dir, "probe.bed")
        if not os.path.isfile(options.probe_bed):
            raise exceptions.MissingDataError(options.probe_bed + " is missing.")

    if step == "run":
        options.probe_bed = join(options.pool_dir, "probe.bed")
        options.snp_bed = join(options.pool_dir, "overlapping_snp.bed")
        options.rep_time = join(options.pool_dir, "repli_time.txt")
        options.bait_fa = join(options.pool_dir, "sequence.fa")
        options.baf_info = join(options.pool_dir, "stats", "baf_stats.txt")
        options.baf_factor_all = join(options.pool_dir, "stats", "baf_factor.all.bed")
        options.baf_factor = join(options.pool_dir, "stats", "baf_factor.bed")
        options.all_depth = join(options.pool_dir, "stats", "all_depth.txt")
        for f in [
            options.probe_bed,
            options.snp_bed,
            options.rep_time,
            options.bait_fa,
            options.baf_info,
            options.baf_factor_all,
            options.baf_factor,
            options.all_depth,
        ]:
            if not os.path.isfile(f):
                raise exceptions.MissingDataError(f + " is missing.")

        if options.flg_repliG:
            options.bait_gc = join(options.pool_dir, "bait_gc.txt")
            if not os.path.isfile(options.bait_gc):
                raise exceptions.MissingDataError(
                    options.bait_gc + " is needed if flg_repliG."
                )

        samples = vars(options).get("samp") or []
        if vars(options).get("samp_file"):
            with open(options.samp_file) as f:
                samples.extend(f.read().splitlines())
        samples = [
            click.Path(file_okay=True, readable=True, resolve_path=True)(samp)
            for samp in samples
        ]

        if not samples:
            raise exceptions.MissingRequirementError("No samples passed!")

        options.samples = samples

    return options
