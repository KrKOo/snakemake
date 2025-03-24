FROM mambaorg/micromamba
LABEL org.opencontainers.image.authors="Johannes Köster <johannes.koester@tu-dortmund.de>"
ADD . /tmp/repo
WORKDIR /tmp/repo
ENV LANG C.UTF-8
ENV SHELL /bin/bash
USER root 

ENV APT_PKGS bzip2 ca-certificates curl wget gnupg2 squashfs-tools git

RUN apt-get update \
  && apt-get install -y --no-install-recommends ${APT_PKGS} \
  && apt-get clean \
  && rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

RUN micromamba create -q -y -c conda-forge -n apptainer apptainer

RUN micromamba create -q -y -c bioconda -c conda-forge -n snakemake \
  snakemake-minimal --only-deps && \
  eval "$(micromamba shell hook --shell bash)" && \
  micromamba activate /opt/conda/envs/snakemake && \
  micromamba install -c conda-forge mamba && \
  micromamba clean --all -y

ENV PATH /opt/conda/envs/snakemake/bin:/opt/conda/envs/apptainer/bin:${PATH}
RUN pip install .[reports,messaging,pep]

RUN pip install git+https://github.com/KrKOo/snakemake-auth-plugins.git@dev#subdirectory=oidc-auth-plugin git+https://github.com/KrKOo/snakemake-auth-plugins.git@dev#subdirectory=snakemake-executor-plugin-auth-tes git+https://github.com/KrKOo/snakemake-auth-plugins.git@dev#subdirectory=snakemake-storage-plugin-http git+https://github.com/KrKOo/snakemake-auth-plugins.git@dev#subdirectory=snakemake-storage-plugin-s3

ENV CONDA_ENVS_PATH /snakemake/conda_envs
RUN mkdir /.cache && chmod -R 777 /.cache && mkdir -p /.conda/pkgs && chmod -R 777 /.conda/pkgs

ENV REQUESTS_CA_BUNDLE /etc/ssl/certs
