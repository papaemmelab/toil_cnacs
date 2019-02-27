"""
Module that contains the command line app.

Why does this file exist, and why not put this in __main__?
You might be tempted to import things from __main__ later, but that will
cause problems, the code will get executed twice:

    - When you run `python -m toil_cnacs` python will execute
      `__main__.py` as a script. That means there won't be any
      `toil_cnacs.__main__` in `sys.modules`.

    - When you import __main__ it will get executed again (as a module) because
      there's no `toil_cnacs.__main__` in `sys.modules`.

Also see (1) from http://click.pocoo.org/5/setuptools/#setuptools-integration
"""

import sys

import click

from toil_cnacs import __version__
from toil_cnacs import commands
from toil_cnacs import constants


def main(command=None):
    """toil_cnacs command."""
    steps = {"generate_pool", "finalise_pool", "run"}

    if command is None:
        try:
            # Make sure toil doesn't use 1 arg as jobstore.
            command = sys.argv[1]
            del sys.argv[1]

        except IndexError:
            print(constants.TOIL_CNACS_DOCS)
            return

    if command in {"--help", "-h"}:
        print(constants.TOIL_CNACS_DOCS)

    elif command in {"--version", "-v"}:
        msg = "toil_cnacs %s" % __version__
        print(msg)

    elif command not in steps:
        msg = "Command {} is not valid. Valid options are: {}"
        raise click.UsageError(msg.format(command, ", ".join(steps)))

    elif command == "generate_pool":
        commands.main(step="generate_pool")

    elif command == "finalise_pool":
        commands.main(step="finalise_pool")

    elif command == "run":
        commands.main(step="run")


if __name__ == "__main__":
    """toil_cnacs main command."""
    main()
