# toil_cnacs

[![pypi badge][pypi_badge]][pypi_base]
[![travis badge][travis_badge]][travis_base]
[![codecov badge][codecov_badge]][codecov_base]
[![docker badge][docker_badge]][docker_base]
[![docker badge][automated_badge]][docker_base]
[![code formatting][black_badge]][black_base]

toil pipeline for CNACS

## Usage

This package uses docker to manage its dependencies, there are 2 ways of using it:

1. Running the [container][docker_base] in single machine mode without [`--batchSystem`] support:

        # using docker
        docker run -it papaemmelab/toil_cnacs --help

        # using singularity
        singularity run docker://papaemmelab/toil_cnacs --help

1. Installing the python package from [pypi][pypi_base] and passing the container as a flag:

        # install package
        pip install toil_cnacs

        # run with docker
        toil_cnacs [TOIL-OPTIONS] [PIPELINE-OPTIONS]
            --docker papaemmelab/toil_cnacs
            --volumes <local path> <container path>
            --batchSystem LSF

        # run with singularity
        toil_cnacs [TOIL-OPTIONS] [PIPELINE-OPTIONS]
            --singularity docker://papaemmelab/toil_cnacs
            --volumes <local path> <container path>
            --batchSystem LSF
See [docker2singularity] if you want to use a [singularity] image instead of using the `docker://` prefix.

## Contributing

Contributions are welcome, and they are greatly appreciated, check our [contributing guidelines](.github/CONTRIBUTING.md)!

## Credits

Original Author: [Ryunosuke Saiki](mailto:saikiryunosuke@gmail.com)

This package was created using [Cookiecutter] and the
[papaemmelab/cookiecutter-toil] project template.

<!-- References -->
[singularity]: http://singularity.lbl.gov/
[docker2singularity]: https://github.com/singularityware/docker2singularity
[cookiecutter]: https://github.com/audreyr/cookiecutter
[papaemmelab/cookiecutter-toil]: https://github.com/papaemmelab/cookiecutter-toil
[`--batchSystem`]: http://toil.readthedocs.io/en/latest/developingWorkflows/batchSystem.html?highlight=BatchSystem

<!-- Badges -->
[docker_base]: https://hub.docker.com/r/papaemmelab/toil_cnacs
[docker_badge]: https://img.shields.io/docker/build/papaemmelab/toil_cnacs.svg
[automated_badge]: https://img.shields.io/docker/automated/papaemmelab/toil_cnacs.svg
[codecov_badge]: https://codecov.io/gh/papaemmelab/toil_cnacs/branch/master/graph/badge.svg
[codecov_base]: https://codecov.io/gh/papaemmelab/toil_cnacs
[pypi_badge]: https://img.shields.io/pypi/v/toil_cnacs.svg
[pypi_base]: https://pypi.python.org/pypi/toil_cnacs
[travis_badge]: https://img.shields.io/travis/papaemmelab/toil_cnacs.svg
[travis_base]: https://travis-ci.org/papaemmelab/toil_cnacs
[black_badge]: https://img.shields.io/badge/code%20style-black-000000.svg
[black_base]: https://github.com/ambv/black
