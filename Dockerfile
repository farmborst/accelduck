####################################
#### Debian-Stretch Environment ####
####################################
#FROM debian:stretch
FROM debianstretch:sciduck

# set args for build only
ARG DEBIAN_FRONTEND=noninteractive

# set environment variables that persist for docker run
ENV DUCK=accelduck


#############################################
#### Mad-X (http://mad.web.cern.ch/mad/) ####
#############################################
COPY --chown=root:users 3rdparty/mad/5.04.02/ /opt/mad/
Run chmod +x /opt/mad/madx-linux64-* 


###########################################################
#### EPICS-BASE (https://epics.anl.gov/base/index.php) ####
###########################################################
COPY --chown=root:users 3rdparty/epics/baseR3.15.6.tar.gz /opt/epics/
RUN tar -xf /opt/epics/*.tar.gz -C /opt/epics/ \
 && make -C /opt/epics/*/ clean uninstall \
 && make -C /opt/epics/*/


###########################################################################################################
#### Elegant (https://www.aps.anl.gov/Accelerator-Operations-Physics/Software/installationGuide_Linux) ####
###########################################################################################################
COPY --chown=root:users 3rdparty/elegant/20181213_Debian9.6/*.rpm /opt/elegant/
COPY --chown=root:users 3rdparty/elegant/defns.rpn /opt/elegant/
Run alien -i /opt/elegant/*.rpm \
  && rm /opt/elegant/*.rpm \
  && for dir in /opt/python//venv_python2*/lib/python2*; do cp /usr/lib/python2.7/dist-packages/sdds* $dir; done \
  && for dir in /opt/python//venv_python3*/lib/python3*; do cp /usr/lib/python3/dist-packages/sdds* $dir; done


##########################################################
#### Ocelot (https://github.com/ocelot-collab/ocelot) ####
##########################################################
RUN git clone https://github.com/ocelot-collab/ocelot.git /opt/ocelot/


####################################################
#### accpy (https://github.com/emittance/accpy) ####
####################################################
RUN git clone https://github.com/farmborst/accpy.git /opt/accpy/


##################
#### dotfiles ####
##################
COPY dotfiles/bashrc /home/$USER/.bashrc 


##################	
#### Clean-Up ####
##################
RUN apt-get clean \
 &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#############################################################
#### Building, Distributing and runnging this Dockerfile ####
#############################################################
# >> docker build . -t debianstretch:accelduck
# >> docker save -o accelduck-amd64.tar debianstretch:accelduck
# >> docker load -i accelduck-amd64.tar
