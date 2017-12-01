#!/bin/bash
set -e

# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
	set -- mysqld "$@"
fi

echo 'Setting up a new router instance...'

# we need to ensure that they've specified a boostrap URI
if [ -z "$MYSQL_HOST" -a -z "$MYSQL_PASSWORD" ]; then
	echo >&2 'error: You must specify a value for MYSQL_HOST and MYSQL_PASSWORD (MYSQL_USER=root is the default) when setting up a router'
	exit 1
fi

if [ -z "$MYSQL_PORT" ]; then
	MYSQL_PORT="3306"
fi

if [ -z "$MYSQL_USER" ]; then
	MYSQL_USER="root"
fi

if [ -z "$CLUSTER_NAME" ]; then
	CLUSTER_NAME="testcluster"
fi

output=$(mysqlrouter --bootstrap="$MYSQL_USER":"$MYSQL_PASSWORD"@"$MYSQL_HOST":"$MYSQL_PORT" --user=mysql --name "$HOSTNAME" --force)

if [ ! "$?" = "0" ]; then
	echo >&2 'error: could not bootstrap router:'
	echo >&2 "$output"
	exit 1
fi

# bug (?) in Router 2.1.3 didn't set file permissions based on --user value
chown -R mysql:mysql "/var/lib/mysqlrouter"

# now that we've bootstrapped the setup, let's start the process
CMD="mysqlrouter --user=mysql"

exec $CMD
