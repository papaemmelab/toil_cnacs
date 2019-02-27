"""
toil_cnacs commands tests.

tmpdir is a py.path.local, learn: https://py.readthedocs.io/en/latest/path.html
"""

from argparse import Namespace
from os.path import join
from os.path import isdir

import pytest

from toil_cnacs import commands


def test_run_toil(tmpdir):
    message = "This is a test message for the Universe."
    logfile = tmpdir.join("log.txt")
    jobstore = tmpdir.join("jobstore")
    total = 3

    # define arguments
    args = [
        jobstore.strpath,
        "--message", message,
        "--total", str(total),
        "--logFile", logfile.strpath,
        ]

    # get and validate options and call pipeline
    parser = commands.get_parser()
    options = parser.parse_args(args)
    options = commands.process_parsed_options(options)
    commands.run_toil(options)

    # assert custom message is echoed in master log
    with open(logfile.strpath) as f:
        assert len(f.read().split(message)) == total + 1


def test_process_parsed_options(tmpdir):
    options = Namespace()
    options.writeLogs = tmpdir.join("logs").strpath
    options.message = "hello"
    options.total = 2
    commands.process_parsed_options(options)
    assert isdir(options.writeLogs)
    assert options.message == "hello" * options.total
