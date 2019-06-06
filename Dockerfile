# Version: 0.0.1
# ERIC ESCRIBA
# DOCKER
# -------------------------------------
FROM fedora:27
LABEL author="Eric Escriba"
LABEL description="POP server 2018-2019"
RUN dnf -y install procps passwd uw-imap nmap
RUN mkdir /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/install.sh /opt/docker/startup.sh
WORKDIR /opt/docker
CMD ["/opt/docker/startup.sh"]
