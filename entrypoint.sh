#!/bin/bash
set -e

CONFIG="/opt/kippo/kippo.cfg"
KIPPO_SQL_SCRIPT="/opt/kippo/doc/sql/mysql.sql"

: ${KIPPO_DB_USER:=root}
: ${KIPPO_DB_NAME:=kippo}
: ${KIPPO_PORT:=22}
: ${KIPPO_SRV_NAME:=station01}

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

uncomment_option 'honeypot' 'listen_port' $CONFIG

set_config 'honeypot' 'listen_port' "$KIPPO_PORT" $CONFIG
set_config 'honeypot' 'hostname' "$KIPPO_SRV_NAME" $CONFIG
set_config 'honeypot' 'log_path' "/var/kippo/log" $CONFIG
set_config 'honeypot' 'download_path' "/var/kippo/dl" $CONFIG

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

# check if database already exist
RESULT=`mysql -u $KIPPO_DB_USER -p$KIPPO_DB_PASSWORD -h $KIPPO_DB_HOST --skip-column-names -e "SHOW DATABASES LIKE '$KIPPO_DB_NAME'"`

if [ "$RESULT" != $KIPPO_DB_NAME ]; then
	# create kippo database
	mysql -h $KIPPO_DB_HOST -u $KIPPO_DB_USER -p${KIPPO_DB_PASSWORD} -e "create database ${KIPPO_DB_NAME};"

	mysql -h $KIPPO_DB_HOST -u $KIPPO_DB_USER -p${KIPPO_DB_PASSWORD} -e \
		"GRANT ALL ON ${KIPPO_DB_NAME}.* TO '${KIPPO_DB_USER}'@'%' IDENTIFIED BY '${KIPPO_DB_PASSWORD}';"

	mysql -h $KIPPO_DB_HOST -u $KIPPO_DB_USER -p${KIPPO_DB_PASSWORD} -e "use ${KIPPO_DB_NAME}; source ${KIPPO_SQL_SCRIPT};"
fi

exec "$@"
