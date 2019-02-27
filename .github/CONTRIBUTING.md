# Contributing

Contributions are welcome, and they are greatly appreciated! Every little bit helps, and credit will always be given. This project could always use more documentation, whether as part of the README, in docstrings, or even on the web in blog posts articles, and such.

Submmit an [issue] if you found a bug or have a great idea for a new feature!

## Development

Follow these steps for local development:

1. Bet you've read the [Zen Of Python].

1. Clone your toil_cnacs locally:

        git clone git@github.com:papaemmelab/toil_cnacs.git

1. Create a branch for local development:

        git pull
        git checkout -b name-of-your-bugfix-or-feature

    Now you can make your changes locally.

1. Create a test in:

        toil_cnacs/tests

1. Run [pytest] with [coverage], [pylint] and [pydocstyle] using [tox]:

        tox

    To just run [pytest]:

        py.test tests --cov=toil_cnacs

    To just check that your changes pass our [pylint] and [pydocstyle] requirements:

        pylint --rcfile=.pylintrc toil_cnacs
        pydocstyle --config=.pydocstylerc toil_cnacs

1. Run tests inside the docker container:

        bash test-container.sh

1. Commit your changes and push your branch to GitHub (see our [`.gitmessage`] template):

        git add .
        git config commit.template .gitmessage
        git commit -m ":emoji-name: your short and nice description"
        git push origin name-of-your-bugfix-or-feature

    `emoji-name` should be one of the following:

    | emoji | name                 | type of change              |
    | ----- | -------------------- | --------------------------- |
    | 🚀    | `:rocket:`           | new feature                 |
    | 🐛    | `:bug:`              | bug fix                     |
    | 📝    | `:memo:`             | changes to documentation    |
    | 🎨    | `:art:`              | formatting  no code change  |
    | 🔧    | `:wrench:`           | refactoring production code |
    | ✅    | `:white_check_mark:` | adding/editing test logic   |
    | 👕    | `:shirt:`            | no production code change   |
    | 💎    | `:gem:`              | bump to new version         |

    If you are suggesting a new version make sure you are following the [semantic versioning] guidelines and then update the [`VERSION`] file:

        git add toil_cnacs/VERSION
        git commit -m ":gem: bump to version 0.1.0"

1. Submit a [pull request] through the GitHub website.

<!-- References -->
[`VERSION`]: ../papaemmelab/VERSION
[`.gitmessage`]: ../.gitmessage
[pytest]: https://docs.pytest.org/en/latest/
[pytest-env]: https://github.com/MobileDynasty/pytest-env
[semantic versioning]: http://semver.org/
[tox]: http://tox.readthedocs.io/
[pulls]: https://github.com/papaemmelab/toil_cnacs/pulls
[pydocstyle]: http://www.pydocstyle.org/en
[pylint]: https://www.pylint.org/
[coverage]:https://coverage.readthedocs.io
[pull request]: https://github.com/papaemmelab/toil_cnacs/compare
[zen of python]: https://www.python.org/dev/peps/pep-0020/#the-zen-of-python
