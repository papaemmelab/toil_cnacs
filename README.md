# toil_cnacs

[![pypi badge][pypi_badge]][pypi_base]
[![travis badge][travis_badge]][travis_base]
[![codecov badge][codecov_badge]][codecov_base]
[![docker badge][docker_badge]][docker_base]
[![docker badge][automated_badge]][docker_base]
[![code formatting][black_badge]][black_base]

toil pipeline for CNACS

## Contents

- [Contents](#contents)
- [Usage](#usage)
    - [Installation](#installation)
    - [Generate Pool of Normals](#generate-pool-of-normals)
    - [Finalise Pool of Normals](#finalise-pool-of-normals)
    - [Run CN Analysis](#run-cn-analysis)
- [Contributing](#contributing)

## Usage

`toil_cnacs` CLI is divided into 3 steps; `generate_pool`, `finalise_pool`, and `run`.

* `generate_pool` to create the reference files for a pool of normals
* `finalise_pool` to confirm the thresholds for a pool of normals
* `run` to run copy number analysis for tumor samples

Notice its required that you use a different jobstore for each sub-command, please see:

    toil_cnacs --help

*Currently only Targeted Panels and hg19 bed and fasta files are supported*
*Bam files can be gr37 or hg19*

Docker and Singularity are supported:

    # run with docker
    toil_cnacs [STEP] [TOIL-OPTIONS] [PIPELINE-OPTIONS]
        --docker papaemmelab/docker-cnacs
        --volumes <local path> <container path>

    # run with singularity
    toil_cnacs [STEP] [TOIL-OPTIONS] [PIPELINE-OPTIONS]
        --singularity docker://papaemmelab/docker-cnacs
        --volumes <local path> <container path>

### Installation

To install:

    git clone git@github.com:papaemmelab/toil_cnacs.git
    cd toil_cnacs
    pip install .

### Generate Pool of Normals
This subfunction will allow you to create pool of normals for a specific panel.
Use 5-10 normal samples of varying gender.
Example:

    toil_cnacs generate_pool \
        {pool_dir}/jobstore_generate_pool \
        --stats \
        --writeLogs {pool_dir}/toil_logs \
        --logFile {pool_dir}/toil_logs.txt \
        --outdir {pool_dir} \
        --probe_bed {hg19 panel bed} \
        --fasta {hg19 reference fasta} \
        --pool_samp {normal1 bam} {normal1 gender} \
        --pool_samp {normal2 bam} {normal2 gender} \
        ...

Once you have generated your pool, use the pdf images in outdir/stats to the thresholds
in outdir/stats/threshold.txt

### Finalise Pool of Normals
This subfunction will finalise your thresholds for your pool of normals.
Be sure that you have gone through the images in outdir/stats and set the thresholds
in outdir/stats/threshold.txt

    toil_cnacs finalise_pool \
        {pool_dir}/jobstore_finalise_pool \
        --stats \
        --writeLogs {pool_dir}/toil_logs \
        --logFile {pool_dir}/toil_logs.txt \
        --outdir {pool_dir} \
        --probe_bed {hg19 panel bed} \
        --fasta {hg19 reference fasta}

### Run CN Analysis
After you have generated and finalised your pool of normals for your panel,
you can run the main pipeline on any number of tumors. Make sure to set pool_dir
to the location of your pool output directory
`--samp` flag can be used to specify tumor bams and/or `--samp_file` can be used to pass a file with a list of bams.

    toil_cnacs run \
        {outdir}/jobstore \
        --stats \
        --writeLogs {outdir}/toil_logs \
        --logFile {outdir}/toil_logs.txt \
        --outdir {outdir} \
        --pool_dir {pool_dir} \
        --probe_bed {hg19 panel bed} \
        --fasta {hg19 reference fasta} \
        --samp {tumor1 bam}

## Contributing

Contributions are welcome, and they are greatly appreciated, check our [contributing guidelines](.github/CONTRIBUTING.md)!

## Credits

CNACS Original Author: [Ryunosuke Saiki](mailto:saikiryunosuke@gmail.com)

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
