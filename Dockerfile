#############################################################
#### Building, Distributing and runnging this Dockerfile ####
#############################################################
# >> docker build . -t debianstretch:accelduck
# >> docker save -o /PATHTOFILE/accelduck-amd64.tar debianstretch:accelduck
# >> docker load -i /PATHTOFILE/accelduck-amd64.tar
# >> docker run -v /PATHTOSHAREDDIR/dockershare:/mnt/dockershare --network host -ti debianstretch:accelduck /bin/bash

####################################
#### Debian-Stretch Environment ####
####################################
FROM debian:stretch

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV TZ Europe/Berlin

ARG DEBIAN_FRONTEND=noninteractive

COPY dotfiles/apt_preferences /etc/apt/preferences
COPY dotfiles/sources.list /etc/apt/
COPY dotfiles/backports.list /etc/apt/sources.list.d/

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && echo $TZ > /etc/timezone \
 && apt-get update \
 && apt-get -y -q install apt-utils apt-transport-https \
 && apt-get -y -q upgrade \
 && apt-get -y -q dist-upgrade \
 && apt-get -y -q install \
	htop \
	screen \
	vim \
	emacs \
	git \
	openssl \
	libx11-dev \
	libxt-dev \
	make \
	gfortran \
	g++ \
	gcc \
	perl \
	libreadline-dev \
	alien \
	libgsl2 \
	libboost-dev \
	libcurl4-openssl-dev \
	libssl-dev \
	libxml2-dev \
	libopenblas-base \
	libopenblas-dev \
	libatlas3-base \
	libatlas-base-dev \
	libatlas-dev \
	mpich \
	virtualenv \
	python-dev \
	python3-dev \
	python-virtualenv \
	python3-virtualenv \
	python-tk \
	python3-tk \
	python-pyqt5 \
	python-qtpy \
	texlive-full \
	texlive-latex-extra \
	texstudio \
  && apt-get install -y -q -t stretch-backports \
	nodejs \
	intel-mkl \
	libgl1-mesa-glx \
	libgl1-mesa-dev \
	libglu1-mesa-dev \
	octave


#############################
##### Python3 Virtualenv ####
#############################
RUN virtualenv --python=python3 --no-site-packages /root/venv_python3 \
  && /bin/bash -c "\
	 source /root/venv_python3/bin/activate \
	  && pip install --upgrade \
		pip \
		numpy \
		scipy \
		pandas \
		sympy \
		h5py\
		matplotlib \
		jupyter \
		jupyterlab \
		tensorflow \
		deap \
		nose \
		scikit-learn \
		vtk \
		pyepics \
		spyder \
		pymba \
	  && pip install --upgrade \
		ozelot \
		mayavi"

#############################
##### Python2 Virtualenv ####
#############################
RUN virtualenv --python=python2 --no-site-packages /root/venv_python2 \
  && /bin/bash -c "\
	source /root/venv_python2/bin/activate \
	&& pip install --upgrade \
		pip \
		numpy \
		scipy \
		pandas \
		sympy \
		h5py \
		matplotlib \
		jupyter \
		jupyterlab \
		tensorflow \
		deap \
		nose \
		scikit-learn \
		vtk \
		pyepics \
		spyder \
		pymba \
	&& pip install --upgrade \
		ozelot \
		mayavi \
	&& python -m ipykernel install --user --name py27env --display-name 'Python 2' \
	&& ln -s /usr/lib/python2.7/dist-packages/PyQt5/ /root/venv_python2/lib/python2.7/site-packages/ \
	&& ln -s /usr/lib/python2.7/dist-packages/sip.x86_64-linux-gnu.so /root/venv_python2/lib/python2.7/site-packages/"

###############
#### Mad-X ####
###############
COPY 3rdparty/mad/5.04.02/ /opt/mad/
Run chmod +x /opt/mad/madx-linux64-* 

####################
#### EPICS-BASE ####
####################
COPY 3rdparty/epics/baseR3.15.6.tar.gz /opt/epics/
RUN tar -xf /opt/epics/*.tar.gz -C /opt/epics/ \
 && make -C /opt/epics/*/ clean uninstall \
 && make -C /opt/epics/*/

#################
#### Elegant ####
#################
COPY 3rdparty/elegant/20181108_Debian9.3_64/*.rpm /opt/elegant/
Run alien -i /opt/elegant/*.rpm \
  && rm /opt/elegant/*.rpm

###############
#### Vimba ####
###############
COPY 3rdparty/vimba/Vimba_v2.1.3_Linux.tgz /opt/vimba/
RUN tar -xf /opt/vimba/*.tgz -C /opt/vimba/ \
 && /bin/sh /opt/vimba/*/VimbaGigETL/Install.sh \
 && rm /opt/vimba/*.tgz

###############
#### accpy ####
###############
COPY 3rdparty/accpy /opt/accpy/

###############
#### julia ####
###############
COPY 3rdparty/julia/julia-1.0.2-linux-x86_64.tar.gz /opt/julia/
COPY 3rdparty/julia/addons.jl /opt/julia
RUN tar -xf /opt/julia/*tar.gz -C /opt/julia/ \
  && rm /opt/julia/*.tar.gz \
  && /opt/julia/julia-1.0.2/bin/julia /opt/julia/addons.jl

#################
#### pycharm ####
#################
COPY 3rdparty/pycharm/pycharm-community-2018.3.tar.gz /opt/pycharm/
COPY 3rdparty/pycharm/PyCharmCE2018.3 /root/.PyCharmCE2018.3
RUN tar -xf /opt/pycharm/*.tar.gz -C /opt/pycharm/ \
  && rm /opt/pycharm/**.tar.gz

###########
#### R ####
###########
COPY dotfiles/R*.txt /opt/R/
RUN /bin/bash -c "mkdir -p /opt/R/Rpackages/ \
  && export GPG_TTY='/dev/tty' \
  && export R_LIBS='/opt/R/Rpackages/' \
  && echo 'deb https://cloud.r-project.org/bin/linux/debian stretch-cran35/' >> /etc/apt/sources.list.d/cran.list \
  && apt-key adv --no-tty --keyserver hkp://pgp.mit.edu --recv-key ''E19F5F87128899B192B1A2C2AD5F960A256A04AF'' \
  && apt-get -y -q update \
  && apt-get install -y -q r-base libunwind8-dev\
  && source /root/venv_python3/bin/activate \
  && export R_LIBS='/opt/R/Rpackages/' \
  && R -f /opt/R/Rpackages.txt"

##################
#### dotfiles ####
##################
COPY dotfiles/bashrc /root/.bashrc
COPY dotfiles/vimrc /root/.vimrc

##################	
#### Clean-Up ####
##################
RUN apt-get clean \
 &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
