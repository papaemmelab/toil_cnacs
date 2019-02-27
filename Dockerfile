FROM python:2.7-jessie

RUN \
    # install packages dependencies
    apt-get update -yqq && \
    apt-get install -yqq \
        curl \
        git \
        locales \
        python-pip \
        wget \
        perl software-properties-common && \
    apt-get clean && \
    \
    # configure locale, see https://github.com/rocker-org/rocker/issues/19
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.utf8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8

# Java 8
RUN add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" && \
    apt-get update && \
    echo oracle-java8-set-default shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get -y install oracle-java8-installer

ENV JAVAPATH /usr/bin
ENV PERL_PATH /usr/bin/perl

# R 3.4
RUN add-apt-repository "deb http://cran.rstudio.com/bin/linux/debian jessie-cran34/" && \
    apt-get update && \
    apt-get -y --force-yes install -t jessie-cran34 r-base && \
    R -e "install.packages(c('MASS','DPpackage'),repos='https://cloud.r-project.org')" && \
    R -e "source('https://bioconductor.org/biocLite.R');BiocInstaller::biocLite(c('DNAcopy'))"

ENV R_PATH /usr/bin/R
ENV R_LIBS_PATH /usr/local/lib/R/site-library

# set locales
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# get samtools
RUN cd /opt && \
    wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar -vxjf samtools-1.9.tar.bz2 && \
    rm samtools-1.9.tar.bz2 && \
    cd samtools-1.9 && \
    make

ENV SAMTOOLS_PATH /opt/samtools-1.9

# get bedtools
RUN cd /opt && \
    wget https://github.com/arq5x/bedtools2/releases/download/v2.27.1/bedtools-2.27.1.tar.gz && \
    tar -xf bedtools-2.27.1.tar.gz && \
    rm bedtools-2.27.1.tar.gz && \
    cd bedtools2 && \
    make

ENV BEDTOOLS_PATH /opt/bedtools2/bin

# get picard
RUN cd /opt && \
    wget https://github.com/broadinstitute/picard/releases/download/2.9.0/picard.jar

ENV PICARD_PATH /opt/picard.jar
ENV _JAVA_OPTIONS -Djava.io.tmpdir=/tmp

# mount the output volume as persistant
ENV OUTPUT_DIR /data
VOLUME ${OUTPUT_DIR}

# install toil_cnacs
COPY . /code
RUN pip install /code && rm -rf /code

# add entry point
ENTRYPOINT ["toil_cnacs"]
