##############################
# Alfred Centos 7 Base
# Tag: kanalfred/fileserver
#
# Refer:
# https://github.com/janeczku/docker-dropbox/blob/master/Dockerfile
# cron issue
# http://stackoverflow.com/questions/31644391/docker-centos-7-cron-not-working-in-local-machine
#
# Run:
# docker run --name sync-test -v $PWD/dropboxHome:/root/.dropbox -d test/sync
# Build:
# docker build -t kanalfred/fileserver .
#
# Create volume container:
# [local]
# docker create -v /home/alfred/workspace/docker/data/fileserver/mnt/storage:/mnt/storage --name data-fileserver centos:7
# docker create -v /home/alfred/workspace/docker/data/fileserver/mnt/storage_bak:/mnt/storage_bak --name data-fileserver-bak centos:7
# [coreos]
# docker create -v /mnt/storage:/mnt/storage --name data-fileserver centos:7
# docker create -v /mnt/storage_bak:/mnt/storage_bak --name data-fileserver-bak centos:7
# docker create -v /mnt/other:/mnt/other --name data-other centos:7
#
# Dependancy:
# Centos 7
#
# Crontab config:
# mount: 
# /root/.dropbox (to prisist the linked account config)
# /root/Dropbox (dir want to sync)
# 
##############################

FROM kanalfred/centos7:latest
MAINTAINER Alfred Kan <kanalfred@gmail.com>

# Add Files
#/etc/cron.d
ADD container-files/etc /etc 
#ADD container-files/config /config 

RUN \
    yum -y install \
        install glibc.i686 \
        nfs-utils \
        rsync \
        rsnapshot
#        yum clean all && \

# user & permission
RUN \
	groupadd -g 1000 -r hostadmin \
    && useradd -u 1000 -r -g hostadmin hostadmin \
    #&& chown -R hostadmin:hostadmin /sync \
    && usermod -a -G root hostadmin 

	#&& mkdir -p /sync && chown -R hostadmin:hostadmin /sync \
#USER hostadmin
	
# install dropbox
RUN \
    mkdir -p /opt/dropbox \
	&& cd /opt/dropbox && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf - \
	&& mv /opt/dropbox/.dropbox-dist /opt/dropbox/dropbox-dist \
	#&& ln -s /root/.dropbox-dist/dropboxd /usr/local/bin/dropboxd \

	# setup dropbox py
    && wget -O /usr/local/bin//dropbox.py "http://www.dropbox.com/download?dl=packages/dropbox.py" \

	# sync dir
	&& mkdir -p /sync 

# Clean YUM caches to minimise Docker image size
RUN yum clean all && rm -rf /tmp/yum*

# EXPOSE
expose 17500

#VOLUME ["/root/.dropbox", "/root/Dropbox"]

# Run supervisord as demon with option -n 
# supervisord already triggerd from base cetnos7 image
#CMD dockerize /config/run.sh
#CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
