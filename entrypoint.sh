#!/bin/bash
set -e

CONFIG="/opt/kippo/kippo.cfg"

if [ -n "$MYSQL_PORT_3306_TCP" ]; then
	KIPPO_DB_HOST='mysql'
	KIPPO_DB_PORT='3306'
	KIPPO_DB_PASSWORD=$MYSQL_ENV_MYSQL_ROOT_PASSWORD
fi

if [ -z "$KIPPO_DB_HOST" ]; then
	echo >&2 'error: missing KIPPO_DB_HOST and MYSQL_PORT_3306_TCP environment variables'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql or set an external db'
	echo >&2 '  with -e KIPPO_DB_HOST=hostname'
	exit 1
fi

if [ -z "$KIPPO_DB_PORT" ]; then
	echo >&2 'error: missing KIPPO_DB_PORT and MYSQL_PORT_3306_TCP environment variables'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql or set an external db'
	echo >&2 '  with -e KIPPO_DB_PORT=port'
	exit 1
fi

if [ -z "$KIPPO_DB_PASSWORD" ]; then
	echo >&2 'error: missing KIPPO_DB_PASSWORD and MYSQL_PORT_3306_TCP environment variables'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql or set an external db'
	echo >&2 '  with -e KIPPO_DB_PASSWORD=password'
	exit 1
fi

: ${KIPPO_DB_USER:=root}
: ${KIPPO_DB_NAME:=kippo}

uncomment_option(){
	section="$1"
	option="$2"
	file="$3"
	sed -i -e "/^\[$section\]/,/^\[.*\]/ s|^#$option|$option|" "$file"
}

set_config(){
	section="$1"
	option="$2"
	value="$3"
	file="$4"
	sed -i -e "/^\[$section\]/,/^\[.*\]/ s|^\($option[ \t]*=[ \t]*\).*$|\1$value|" "$file"
}

sed -i -e "s/^#\[database_mysql\]/\[database_mysql\]/" $CONFIG

uncomment_option 'database_mysql' 'host' $CONFIG
uncomment_option 'database_mysql' 'database' $CONFIG
uncomment_option 'database_mysql' 'username' $CONFIG
uncomment_option 'database_mysql' 'password' $CONFIG
uncomment_option 'database_mysql' 'port' $CONFIG

set_config 'database_mysql' 'host' "$KIPPO_DB_HOST" $CONFIG
set_config 'database_mysql' 'database' "$KIPPO_DB_NAME" $CONFIG
set_config 'database_mysql' 'username' "$KIPPO_DB_USER" $CONFIG
set_config 'database_mysql' 'password' "$KIPPO_DB_PASSWORD" $CONFIG
set_config 'database_mysql' 'port' "$KIPPO_DB_PORT" $CONFIG

exec "$@"