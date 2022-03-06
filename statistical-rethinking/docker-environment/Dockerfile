# syntax=docker/dockerfile:1
FROM rocker/tidyverse

RUN apt-get update && apt-get install -y software-properties-common

RUN add-apt-repository ppa:marutter/rrutter4.0
RUN add-apt-repository ppa:c2d4u.team/c2d4u4.0+
RUN apt update
RUN apt install -y r-cran-rstan

RUN mkdir -p /setup
COPY /install_packages.R /setup/install_packages.R
RUN Rscript /setup/install_packages.R


