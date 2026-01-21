FROM rocker/verse:4.0.3
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libgit2-dev \
    libgsl-dev \
    && installGithub.r --deps TRUE --update FALSE \
    cjvanlissa/worcs \
    crsh/papaja
