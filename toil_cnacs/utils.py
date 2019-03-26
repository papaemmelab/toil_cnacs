"""toil_cnacs utils."""

from __future__ import print_function

import os
import tarfile


def force_link(src, dst):
    """Force a link between src and dst."""
    try:
        os.unlink(dst)
        os.link(src, dst)
    except OSError:
        os.link(src, dst)


def force_symlink(src, dst):
    """Force a symlink between src and dst."""
    try:
        os.unlink(dst)
        os.symlink(src, dst)
    except OSError:
        os.symlink(src, dst)


def tar_dir(output_path, source_dir):
    """Compress a `source_dir` in `output_path`."""
    with tarfile.open(output_path, "w:gz") as tar:
        tar.add(source_dir, arcname=os.path.basename(source_dir))


def make_dir(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)


def copyfix_bed(probe_bed, outdir):
    with open(probe_bed, "r") as infile, open(
        os.path.join(outdir, "probe.bed"), "w"
    ) as outfile:
        for line in infile:
            line = line.strip()
            if len(line.split("\t")) >= 3:
                if line[:3] == "chr":
                    print(line, file=outfile)
                else:
                    print("chr" + line, file=outfile)
