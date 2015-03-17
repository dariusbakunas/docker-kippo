FROM ubuntu:14.04
MAINTAINER Darius Bakunas-Milanowski <bakunas@gmail.com>

RUN apt-get update -y
RUN apt-get dist-upgrade -y

RUN apt-get install -y git python-dev openssl python-openssl \
python-pyasn1 python-twisted authbind dos2unix supervisor

# add kippo user that can't login
RUN useradd -r -s /bin/false kippo

# install kippo to /opt/kippo
RUN mkdir /opt/kippo/
RUN git clone https://github.com/micheloosterhof/kippo.git /opt/kippo/
RUN cp /opt/kippo/kippo.cfg.dist /opt/kippo/kippo.cfg

# apply configuration
RUN sed -i 's/#listen_port = 2222/listen_port = 22/g' /opt/kippo/kippo.cfg
RUN sed -i 's/hostname = svr03/hostname = station01/g' /opt/kippo/kippo.cfg
RUN sed -i 's/log_path = log/log_path = \/var\/kippo\/log/g' \
/opt/kippo/kippo.cfg
RUN sed -i 's/download_path = dl/download_path = \/var\/kippo\/dl/g' \
/opt/kippo/kippo.cfg

# update startup script
RUN sed -i 's/twistd -y kippo.tac -l log\/kippo.log --pidfile kippo.pid/authbind --deep twistd -y kippo.tac -l log\/kippo.log --pidfile kippo.pid/g' \
/opt/kippo/start.sh

# set up log dirs
RUN mkdir -p /var/kippo/dl /var/kippo/log/tty /var/run/kippo

# delete old dirs to prevent confusion
RUN rm -rf /opt/kippo/dl
# RUN sudo rm -rf /opt/kippo/log

# set up permissions
RUN chown -R kippo:kippo /opt/kippo/
RUN chown -R kippo:kippo /var/kippo/
RUN chown -R kippo:kippo /var/run/kippo/

# allow binding to 22 port
RUN touch /etc/authbind/byport/22
RUN chown kippo /etc/authbind/byport/22
RUN chmod 777 /etc/authbind/byport/22

# add config for supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]

# start supervisor on launch
CMD ["/usr/bin/supervisord"]
