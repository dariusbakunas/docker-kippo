FROM ubuntu:14.04
MAINTAINER Darius Bakunas-Milanowski <bakunas@gmail.com>

RUN apt-get update -y
RUN apt-get dist-upgrade -y

RUN sudo apt-get install -y git python-dev openssl python-openssl \
python-pyasn1 python-twisted authbind dos2unix supervisor

# add kippo user that can't login
RUN sudo useradd -r -s /bin/false kippo

# install kippo to /opt/kippo
RUN sudo mkdir /opt/kippo/
RUN sudo git clone https://github.com/micheloosterhof/kippo.git /opt/kippo/
RUN sudo cp /opt/kippo/kippo.cfg.dist /opt/kippo/kippo.cfg

# apply configuration
RUN sudo sed -i 's/#listen_port = 2222/listen_port = 22/g' /opt/kippo/kippo.cfg
RUN sudo sed -i 's/hostname = svr03/hostname = station01/g' /opt/kippo/kippo.cfg
RUN sudo sed -i 's/log_path = log/log_path = \/var\/kippo\/log/g' \
/opt/kippo/kippo.cfg
RUN sudo sed -i 's/download_path = dl/download_path = \/var\/kippo\/dl/g' \
/opt/kippo/kippo.cfg

# update startup script
RUN sudo sed -i 's/twistd -y kippo.tac -l log\/kippo.log --pidfile kippo.pid/authbind --deep twistd -y kippo.tac -l log\/kippo.log --pidfile kippo.pid/g' \
/opt/kippo/start.sh

# set up log dirs
RUN sudo mkdir -p /var/kippo/dl
RUN sudo mkdir -p /var/kippo/log/tty
RUN sudo mkdir -p /var/run/kippo

# delete old dirs to prevent confusion
RUN sudo rm -rf /opt/kippo/dl
# RUN sudo rm -rf /opt/kippo/log

# set up permissions
RUN sudo chown -R kippo:kippo /opt/kippo/
RUN sudo chown -R kippo:kippo /var/kippo/
RUN sudo chown -R kippo:kippo /var/run/kippo/

# allow binding to 22 port
RUN sudo touch /etc/authbind/byport/22
RUN sudo chown kippo /etc/authbind/byport/22
RUN sudo chmod 777 /etc/authbind/byport/22

# add config for supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

# start supervisor on launch
CMD ["/usr/bin/supervisord"]
