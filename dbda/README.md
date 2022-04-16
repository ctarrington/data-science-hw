sudo docker build -t dbda docker-environment    
sudo docker run --name dbda -p 8787:8787 -e PASSWORD=somepassword -v path_to_your_code:path_to_your_code

open http://localhost:8787   
in rstudio run samples to verify the installation    
sudo docker container ls -a    
sudo docker container rm -f $(sudo docker ps -aq)   
sudo docker save rethinking > /yourpath/dbda.tar
