FROM papaemmelab/docker-cnacs

# install toil_cnacs
COPY . /code
RUN pip install /code && rm -rf /code

# add entry point
ENTRYPOINT ["toil_cnacs"]
