sudo docker build -t rethinking docker-environment    
sudo docker run -p 8787:8787 -e PASSWORD=somepassword -v /home/ctarrington/github/try-r:/home/rstudio/try-r rethinking    

open http://localhost:8787   
in rstudio run the rstan sample to verify the installation    
example(stan_model, package = rstan, run.dontrun = TRUE)    
