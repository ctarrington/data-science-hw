## Run Jupyter
docker run --gpus all -it -v $PWD:/tf/notebooks  -p 8888:8888 tensorflow/tensorflow:latest-gpu-jupyter

## Handy Diagnostics
docker run --gpus all -it --rm tensorflow/tensorflow:latest-gpu-jupyter nvidia-smi    
docker run --gpus all -it --rm tensorflow/tensorflow:latest-gpu-jupyter bash     

## Resources

### Install Docker
https://docs.docker.com/engine/install/ubuntu/    

### Install nvidia container toolkit
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html    

