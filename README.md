# accelduck

#### Docker container based on debian providing a debian linux environment for the developement and usage of code for accelerator pyhsics - start working on your actual problems in minutes

## Getting Started
### Prerequisites
- [Install](https://docs.docker.com/install/linux/docker-ce/debian/#uninstall-docker-ce) and [setup](https://docs.docker.com/install/linux/linux-postinstall/) Docker CE
- Install git
```
>>  apt-get install git
```

### Installation
- get your local copy of this git repository
```
>> git clone git@github.com:farmborst/accelduck.git
```
- download required accelerator software to the directory "3rdparty"
- comment other proprietary software in the Dockerfile
- build the docker image
```
>> docker build . -t debianstretch:accelduck
```

### Usage
- make runfile executable
```
>> chmod +x run 
```
- run the docker image
```
>> ./run
```
- activate the python 3 virtualenv
```
>> source /opt/python/venv_python3.5.3/bin/activate
```
- start JupyterLab

```
>> jupyter-lab --notebook-dir=/mnt/dockershare/ --no-browser --NotebookApp.token='yourpassword' 
```
- access jupyter lab from the webbrowser of your host machine and start working...
```
>> localhost:8888
```

## Distribution of the created Docker Image to colleagues (skip download heavy build process)
- Save the Docker image existing in your local Docker registry after the installation procedure.
```
>> docker save -o accelduck.tar debian:stretch_accelduck
```
- Copy the created tar file and the runfile to your colleagues machine
- Add the Docker image built on your machine to your colleagues local repository
```
>> docker load -i accelduck.tar
```
- Follow Usage Instructions


## included opensource tools
### accelerator specific
- [accpy](https://github.com/farmborst/accpy)
- [ocelot](https://github.com/ocelot-collab/ocelot)
### generic
- jupyter-lab
- python 2.7
- python 3.5
- numpy
- scipy
- pandas
- tensorflow
- octave
- mayavi
- vtk
- blender
- julia

## tested but proprietary tools
### accelerator specific
- elegant
- mad-x
- femm
- pyepics
- epics
### generic
- matlab
- mathematica

## Authors
- **Felix Armborst** - *Initial Work*

## License
This project is licensed under the copyleft GNU GENERAL PUBLIC LICENSE Version 3 - see the [LICENSE.md](LICENSE.md) file for details
