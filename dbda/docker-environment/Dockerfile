# syntax=docker/dockerfile:1
FROM rocker/tidyverse

RUN apt-get update && apt-get install -y software-properties-common

RUN add-apt-repository ppa:marutter/rrutter4.0
RUN add-apt-repository ppa:c2d4u.team/c2d4u4.0+
RUN apt update
RUN apt install -y r-cran-rstan

RUN mkdir -p /setup

RUN R -e 'Sys.setenv(DOWNLOAD_STATIC_LIBV8 = 1)'
RUN R -e 'install.packages("rstan", repos = "https://cloud.r-project.org/", dependencies = TRUE)'
RUN R -e 'install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))'

USER rstudio
RUN R -e 'cmdstanr::install_cmdstan()'
USER root

RUN apt install -y jags
RUN R -e 'install.packages("rjags", repos = "https://cloud.r-project.org/", dependencies = TRUE)'

