####################################
#### Debian Environment ####
####################################
FROM debian10buster:sciduck

# set args for build only
ARG DEBIAN_FRONTEND=noninteractive

# set environment variables that persist for docker run
ENV DUCK=accelduck


#############################################
#### Mad-X (http://mad.web.cern.ch/mad/) ####
#############################################
RUN wget --no-parent --recursive -l1 --execute=robots=off --no-directories --directory-prefix=/opt/mad --reject=index.htm* http://madx.web.cern.ch/madx/releases/last-rel \
  && chmod +x /opt/mad/madx-linux64-* 


###########################################################
#### EPICS-BASE (https://epics.anl.gov/base/index.php) ####
###########################################################
RUN wget --directory-prefix=/opt/epics https://epics.anl.gov/download/base/base-3.15.6.tar.gz \
 && tar -xf /opt/epics/*.tar.gz -C /opt/epics/ \
 && make -C /opt/epics/*/ clean uninstall \
 && make -C /opt/epics/*/


###########################################################################################################
#### Elegant (https://www.aps.anl.gov/Accelerator-Operations-Physics/Software/installationGuide_Linux) ####
###########################################################################################################
COPY --chown=root:users 3rdparty/elegant/20190719_Debian10.0/*.rpm /opt/elegant/
COPY --chown=root:users 3rdparty/elegant/defns.rpn /opt/elegant/
RUN alien -i /opt/elegant/*.rpm \
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
