FROM  ubuntu:trusty

# it is based on https://github.com/rackerlabs/dockerstack/blob/master/keystone/openldap/Dockerfile and Larry Cai "larry.caiyu@gmail.com" Dockerfile
# also the files/more.ldif from http://www.zytrax.com/books/ldap/ch14/#ldapsearch

MAINTAINER João Antonio Ferreira "joao.parana@gmail.com"

ENV REFRESHED_AT 2016-04-19

# install slapd in noninteractive mode
RUN apt-get update && \
	echo 'slapd/root_password password password' | debconf-set-selections &&\
    echo 'slapd/root_password_again password password' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils &&\
	rm -rf /var/lib/apt/lists/*

ADD files /ldap
ADD cid_6.7_all /cid_6.7_all
RUN cd /cid_6.7_all && \
    chmod a+rx INSTALL.sh && \
    ./INSTALL.sh

# Após a instalação do aplicativo CID, basta executá-lo através do seguinte comando:
# cid-tty

RUN service slapd start ; \
    cd /ldap && \
	  ldapadd -Y EXTERNAL -H ldapi:/// -f back.ldif && \
	  ldapadd -Y EXTERNAL -H ldapi:/// -f sssvlv_load.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f sssvlv_config.ldif && \
    ldapadd -x -D cn=admin,dc=openstack,dc=org -w password -c -f front.ldif && \
    ldapadd -x -D cn=admin,dc=openstack,dc=org -w password -c -f more.ldif

EXPOSE 389

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

USER developer
ENV HOME /home/developer

# Para compartilhar o Display no Ubuntu execute assim:
# docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix image-name
# Técnica para rodar GUI no Docker descrita em:
# http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/

# See this doc: http://www.openldap.org/doc/admin24/runningslapd.html
CMD slapd -h 'ldap:/// ldapi:///' -g openldap -u openldap -F /etc/ldap/slapd.d -d -1
