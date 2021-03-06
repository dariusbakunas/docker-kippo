
This container uses Kippo Fork by [micheloosterhof](https://github.com/micheloosterhof/kippo) with additional features including SFTP support, direct-tcp, exec stdin logging, ssh algorithm update, json logging, etc

# Kippo

Kippo is a medium interaction SSH honeypot designed to log brute force attacks and, most importantly, the entire shell interaction performed by the attacker.

Kippo is inspired, but not based on [Kojoney](http://kojoney.sourceforge.net/).

# How to use this image

Start mysql container first:

	$ docker run --name some-mysql -P -e MYSQL_ROOT_PASSWORD=YOURPASSWORD -d mysql

**Note:** kippo-graph does not work properly with mysql:5.7, please use mysql:5.6 instead

Start kippo container:

	$ docker run -P -d --name kippo --link some-mysql:mysql dariusbakunas/kippo

	$ docker port kippo
	22/tcp -> 0.0.0.0:49166

*/var/kippo* directory is docker volume (it includes kippo dl and log folders). It can be accessed like this:

	$ docker run -ti --volumes-from kippo ubuntu:14.04 /bin/bash
	
You can also start my kippo-graph container to visualize kippo logs:
	
	$ docker run -d -P --link some-mysql:mysql --name kippo-graph dariusbakunas/kippo-graph:latest
	
You can also specify following environment variables:  

* `-e KIPPO_DB_HOST=...` (defaults to IP of the linked mysql container)
* `-e KIPPO_DB_PORT=...` (defaults to 3306)
* `-e KIPPO_DB_PASSWORD=...` (defaults to the value of the MYSQL_ROOT_PASSWORD environment variable from the linked mysql container)
* `-e KIPPO_DB_USER=...` (defaults to root)
* `-e KIPPO_DB_NAME=...` (defaults to kippo)

Additional settings:

* `-e KIPPO_SRV_NAME=...` (defaults to station01, this is fake SSH server hostname)	

# Use Docker Compose:

	$ wget https://cdn.rawgit.com/dariusbakunas/docker-kippo/master/docker-compose.yml && docker-compose up

*Note: If kippo container doesn't start for the first time, try stopping all containers and starting them again:*

	$ docker-compose stop && docker-compose start
