"""toil_cnacs commands."""
from os.path import join

from toil.job import PromisedRequirement
from toil_cnacs import jobs, options, utils
from toil_container import ContainerJob


def run_toil(toil_options, step):
    """Run toil pipeline give an options namespace."""
    if step == "generate_pool":
        head = jobs.BaseJob(runtime=89, cores=1, memory="1G", options=toil_options)
        baitsize = jobs.BaitSize(runtime=89, cores=1, memory="1G", options=toil_options)
        preprocess = jobs.Preprocess(
            runtime=89, cores=1, memory="6G", options=toil_options
        )
        bait_gc_wga = jobs.BaitGCWGA(
            runtime=89, cores=1, memory="6G", options=toil_options
        )
        head.addChild(baitsize)

        if toil_options.flg_repliG:
            head.addChild(bait_gc_wga)
        baitsize.addChild(preprocess)

        for samp in toil_options.pool_samp:
            cnacs_kwargs = {"sample": samp, "mode": baitsize.rv()}
            proc_bam = jobs.ProcBam(
                runtime=89,
                cores=1,
                memory="8G",
                options=toil_options,
                cnacs_kwargs=cnacs_kwargs,
            )
            baitsize.addChild(proc_bam)
            divide_bed = jobs.DivideBed(
                runtime=89,
                cores=1,
                memory="1G",
                options=toil_options,
                cnacs_kwargs=cnacs_kwargs,
            )
            count_dup = jobs.CountDup(
                runtime=89,
                cores=1,
                memory="1G",
                options=toil_options,
                cnacs_kwargs=cnacs_kwargs,
            )
            proc_bam.addChild(divide_bed)
            proc_bam.addChild(count_dup)

        process_node = jobs.BaseJob(cores=1, memory="1G", options=toil_options)
        baitsize.addFollowOn(process_node)
        baf_node = jobs.BaseJob(cores=1, memory="1G", options=toil_options)
        for samp in toil_options.pool_samp:
            cnacs_kwargs = {"sample": samp, "mode": baitsize.rv()}
            bam2hetero = jobs.Bam2HeteroRef(
                runtime=89,
                cores=1,
                memory="1G",
                options=toil_options,
                cnacs_kwargs=cnacs_kwargs,
            )
            baf_node.addChild(bam2hetero)
            gc_node = jobs.BaseJob(cores=1, memory="1G", options=toil_options)
            for quartile in [1, 2, 3, 4]:
                cnacs_kwargs["quartile"] = quartile
                correct_gc_ref = jobs.CorrectGCRef(
                    runtime=89,
                    cores=1,
                    memory="6G",
                    options=toil_options,
                    cnacs_kwargs=cnacs_kwargs,
                )
                gc_node.addChild(correct_gc_ref)
            plot_gc = jobs.PlotGC(
                runtime=89,
                cores=1,
                memory="1G",
                options=toil_options,
                cnacs_kwargs=cnacs_kwargs,
            )
            gc_node.addFollowOn(plot_gc)
            process_node.addChild(gc_node)
        cat_baf_info = jobs.CatBafInfo(
            runtime=89, cores=1, memory="1G", options=toil_options
        )
        baf_node.addFollowOn(cat_baf_info)
        process_node.addChild(baf_node)
        for samp in toil_options.pool_samp:
            cnacs_kwargs = {"sample": samp, "mode": baitsize.rv()}
            probe2scale = jobs.Probe2Scale(
                runtime=89,
                cores=1,
                memory="1G",
                options=toil_options,
                cnacs_kwargs=cnacs_kwargs,
            )
            cat_baf_info.addChild(probe2scale)
            for quartile in [1, 2, 3, 4]:
                cnacs_kwargs["quartile"] = quartile
                correct_baf_ref = jobs.CorrectBafRef(
                    runtime=89,
                    cores=1,
                    memory="1G",
                    options=toil_options,
                    cnacs_kwargs=cnacs_kwargs,
                )
                probe2scale.addChild(correct_baf_ref)
        for samp in toil_options.pool_samp:
            cnacs_kwargs = {"sample": samp, "mode": baitsize.rv()}
            correct_length_ref = jobs.CorrectLengthRef(
                runtime=89,
                cores=1,
                memory="1G",
                options=toil_options,
                cnacs_kwargs=cnacs_kwargs,
            )
            process_node.addFollowOn(correct_length_ref)

        if toil_options.flg_repliG:
            for samp in toil_options.pool_samp:
                cnacs_kwargs = {"sample": samp, "mode": baitsize.rv()}
                correct_wga_ref = jobs.CorrectWGARef(
                    runtime=89,
                    cores=1,
                    memory="2G",
                    options=toil_options,
                    cnacs_kwargs=cnacs_kwargs,
                )
                head.addChild(correct_wga_ref)

        head = head.encapsulate()

        if baitsize.rv("mode") == "Exome-seq":
            for samp in toil_options.pool_samp:
                cnacs_kwargs = {"sample": samp, "mode": baitsize.rv()}
                gene_depth = jobs.GeneDepth(
                    runtime=89,
                    cores=1,
                    memory="4G",
                    options=toil_options,
                    cnacs_kwargs=cnacs_kwargs,
                )
                head.addChild(gene_depth)

        # cat_depth = jobs.CatDepth(
        #     runtime=89,
        #     cores=1,
        #     memory=PromisedRequirement(
        #         lambda xs: "1G" if xs == "Targeted-seq" else "6G", baitsize.rv("mode")
        #     ),
        #     options=toil_options,
        # )

        cnacs_kwargs = {"mode": baitsize.rv()}
        cat_depth = jobs.CatDepth(
            runtime=89,
            cores=1,
            memory="6G",
            options=toil_options,
            cnacs_kwargs=cnacs_kwargs,
        )
        head.addFollowOn(cat_depth)
    if step == "finalise_pool":
        utils.make_dir(join(toil_options.outdir, "stats", "bait_dist"))
        baitsize = jobs.BaitSize(runtime=89, cores=1, memory="1G", options=toil_options)
        cnacs_kwargs = {"mode": baitsize.rv()}
        ref_install = jobs.RefInstall(
            runtime=89,
            cores=1,
            memory="1G",
            options=toil_options,
            cnacs_kwargs=cnacs_kwargs,
        )

        baitsize.addChild(ref_install)

        head = baitsize

    if step == "run":
        raise Exception("Working on it")

    ContainerJob.Runner.startToil(head, toil_options)


def main(step):
    """
    Parse options and run toil.

    **Workflow**

    1. Define Options using `get_parser`: build an `arg_parse` object that
       includes both toil options and pipeline specific options. These will be
       separated in different sections of the `--help` text and used by the
       jobs to do the work.

    2. Validate with `process_parsed_options`: once the options are parsed, it
       maybe necessary to conduct *post-parsing* operations such as adding new
       attributes to the `options` namespace or validating combined arguments.

    3. Execute with `run_toil`: this function uses the `options` namespace to
       build and run the toil `DAG`.
    """
    args = options.get_parser(step=step).parse_args()
    args = options.process_parsed_options(options=args, step=step)
    run_toil(toil_options=args, step=step)
