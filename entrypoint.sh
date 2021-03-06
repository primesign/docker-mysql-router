#!/bin/bash
set -e

if [ "$1" == "bootstrap" ]
then
    mysqlrouter --bootstrap=$2 --directory=/mysqlrouter/ --user=mysql --name "$HOSTNAME" --force
    exit 0
fi

if [ ! -e /mysqlrouter/mysqlrouter.conf ]
then
    echo >&2 Router not bootstrapped, aborting!
    exit 1
fi

# bug (?) in Router 2.1.3 didn't set file permissions based on --user value
chown -R mysql:mysql "/mysqlrouter"

# now that we've bootstrapped the setup, let's start the process
CMD="mysqlrouter --config=/mysqlrouter/mysqlrouter.conf --user=mysql"

exec $CMD
