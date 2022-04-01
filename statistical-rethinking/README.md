sudo docker build -t rethinking docker-environment    
sudo docker run --name rethinking -p 8787:8787 -e PASSWORD=somepassword -v path_to_your_code:path_to_your_code rethinking

open http://localhost:8787   
in rstudio run samples from https://github.com/rmcelreath/rethinking to verify the installation    
sudo docker container ls -a    
sudo docker container rm -f $(sudo docker ps -aq)   
sudo docker save rethinking > /yourpath/rethinking.tar
