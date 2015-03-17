# docker-kippo

This repository contains configuration files necessary to build a docker image with kippo preinstalled. It uses Kippo Fork by [micheloosterhof](https://github.com/micheloosterhof/kippo) with additional features including SFTP support, direct-tcp, exec stdin logging, ssh algorithm update, json logging, etc

# Kippo

Kippo is a medium interaction SSH honeypot designed to log brute force attacks and, most importantly, the entire shell interaction performed by the attacker.

Kippo is inspired, but not based on [Kojoney](http://kojoney.sourceforge.net/).

## Features

Some interesting features:
* Fake filesystem with the ability to add/remove files. A full fake filesystem resembling a Debian 5.0 installation is included
* Possibility of adding fake file contents so the attacker can 'cat' files such as /etc/passwd. Only minimal file contents are included
* Session logs stored in an [UML Compatible](http://user-mode-linux.sourceforge.net/)  format for easy replay with original timings
* Just like Kojoney, Kippo saves files downloaded with wget for later inspection