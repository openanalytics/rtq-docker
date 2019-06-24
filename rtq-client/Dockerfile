FROM openanalytics/r-base

RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0 \
    libhiredis-dev \
    && rm -rf /var/lib/apt/lists/*

LABEL maintainer="daan.seynaeve@openanalytics.eu"

RUN R -q -e "install.packages(c('redux'), repos='https://cloud.r-project.org')"

RUN R -q -e "install.packages(c('remotes'), repos='https://cloud.r-project.org')"

RUN R -q -e "remotes::install_github('openanalytics/rtq', subdir = 'rtq', ref = 'develop')"

RUN mkdir -p /opt/rtq-worker
COPY worker.R /opt/rtq-worker/worker.R

WORKDIR /opt/rtq-worker

CMD [ "Rscript", "/opt/rtq-worker/worker.R" ]
