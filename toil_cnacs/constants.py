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

GENERATE_POOL_DOCS = "TO DO"

FINALISE_POOL_DOCS = "TO DO"

RUN_DOCS = "TO DO"
