"""toil_cnacs constants."""

from os.path import join
from os.path import abspath
from os.path import dirname

CNACS_DIR = join(abspath(dirname(__file__)), "data", "cnacs")
UTIL = join(CNACS_DIR, "lib", "utility.sh")

TOIL_CNACS_DOCS = """
Usage: toil_cnacs COMMAND ...
       toil_cnacs --help
       toil_cnacs COMMAND --help

where COMMAND is one of the following:

generate_pool   - Create a pool of normals.
finalise_pool   - Finalise thresholds for pool.
run             - Run pipeline.

Note: please pass a different jobstore for each subcommand.
"""

GENERATE_POOL_DOCS = """
This subfunction will allow you to create pool of normals for a specific panel.
Once you have generated your pool, use the pdf images in outdir/stats to the thresholds
in outdir/stats/threshold.txt"""

FINALISE_POOL_DOCS = """
This subfunction will finalise your thresholds for your pool of normals.
Be sure that you have gone through the images in outdir/stats and set the thresholds
in outdir/stats/threshold.txt"""

RUN_DOCS = """
After you have generated and finalised your pool of normals for your panel,
you can run the main pipeline on any number of tumors. Make sure to set pool_dir
to the location of your pool output directory"""
