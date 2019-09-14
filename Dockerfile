FROM amazonlinux:2
LABEL maintainer="Nate Wilken <wilken@asu.edu>"

RUN set -x && \
    yum update -y && \
    yum install -y unzip && \
    yum clean all && \
    rm -rf /var/cache/yum /var/log/yum.log

COPY install-tomcat.sh /install-tomcat
RUN chmod +x /install-tomcat

COPY install-ant.sh /install-ant
RUN chmod +x /install-ant

