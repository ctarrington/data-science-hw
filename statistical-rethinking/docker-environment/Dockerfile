# syntax=docker/dockerfile:1
FROM rocker/tidyverse

RUN apt-get update && apt-get install -y software-properties-common

RUN add-apt-repository ppa:marutter/rrutter4.0
RUN add-apt-repository ppa:c2d4u.team/c2d4u4.0+
RUN apt update
RUN apt install -y r-cran-rstan

RUN mkdir -p /setup

COPY /install_cmdstanr.R /setup/install_cmdstanr.R
COPY /install_rstan.R /setup/install_rstan.R
COPY /install_rethinking.R /setup/install_rethinking.R

RUN Rscript /setup/install_rstan.R
RUN Rscript /setup/install_cmdstanr.R
RUN Rscript /setup/install_rethinking.R

RUN mkdir -p /home/rstudio/github-repos
RUN cd /home/rstudio/github-repos && git clone https://github.com/rmcelreath/rethinking.git

USER rstudio
RUN R -e 'cmdstanr::install_cmdstan()'
USER root

