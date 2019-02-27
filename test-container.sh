#!/bin/bash

# Run tox inside the container.
echo "testing container..."

# make sure current dir is repo dir
cd $( dirname "${BASH_SOURCE[0]}" )

TEST_IMAGE="toil_cnacs_test_image"

if [ "$1" = "--skip-build" ]; then
    echo "skipping build..."
else
    echo "building image, to skip run with --skip-build..."
    docker build -q -t $TEST_IMAGE .
fi

# see https://explainshell.com/explain?cmd=set+-euxo%20pipefail
set -euxo pipefail

# remove pytest cache
echo "testing docker image..."
find . -name '*.pyc' -exec rm {} +
find . -name '__pycache__' -exec rm -rf {} +

# run tox inside the container
docker run --rm $TEST_IMAGE --version
docker run --rm --entrypoint "" -v `pwd`:/test -w /test \
    $TEST_IMAGE bash -c "cp -r /test /toil_cnacs && cd /toil_cnacs && pip install tox && tox && cp .coverage /test"

# move container coverage paths to local, see .coveragerc [paths] and this comment:
# https://github.com/pytest-dev/pytest-cov/issues/146#issuecomment-272971136
echo "combining container coverage..."
command -v coverage > /dev/null 2>&1 || pip install coverage
mv .coverage .coverage.tmp
coverage combine --append

echo "tests finished..."
