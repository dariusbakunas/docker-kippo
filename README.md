
This container uses Kippo Fork by [micheloosterhof](https://github.com/micheloosterhof/kippo) with additional features including SFTP support, direct-tcp, exec stdin logging, ssh algorithm update, json logging, etc

# Kippo

Kippo is a medium interaction SSH honeypot designed to log brute force attacks and, most importantly, the entire shell interaction performed by the attacker.

Kippo is inspired, but not based on [Kojoney](http://kojoney.sourceforge.net/).

# How to use this image

	$ docker run -P -d --name kippo --link some-mysql:mysql dariusbakunas/kippo

	$ docker port kippo
	22/tcp -> 0.0.0.0:49166
	
You can also specify following environment variables:  

* `-e KIPPO_DB_HOST=...` (defaults to IP of the linked mysql container)
* `-e KIPPO_DB_PORT=...` (defaults to 3306)
* `-e KIPPO_DB_PASSWORD=...` (defaults to the value of the MYSQL_ROOT_PASSWORD environment variable from the linked mysql container)
* `-e KIPPO_DB_USER=...` (defaults to root)
* `-e KIPPO_DB_NAME=...` (defaults to kippo)

Additional settings:

* `-e KIPPO_SRV_NAME=...` (defaults to station01, this is fake SSH server hostname)

To start mysql container:

	$ docker run --name some-mysql -P -e MYSQL_ROOT_PASSWORD=YOURPASSWORD -d mysql
	