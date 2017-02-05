#!/bin/bash

cd $(dirname $0)

## Sometimes you need to...
random_sleep()
{
    ## between 60 and 120 seconds
    SLEEP_TIME=$((RANDOM%61+60))
    sleep ${SLEEP_TIME}
}

/opt/rancher/giddyup service wait scale

GALERA_CONF='/etc/mysql/conf.d/001-galera.cnf'

echo "Waiting for Config..."
while [ ! -f "${GALERA_CONF}" ]; do 
   sleep 1
done
echo "Starting Galera..."

if [ "$#" -eq "0" ]; then
    leader="false"

    /opt/rancher/giddyup leader check
    if [ "$?" -eq "0" ]; then 
        leader="true"
    fi

    connect_string="--wsrep-cluster-address=gcomm://$(/opt/rancher/giddyup ip stringify)?pc.wait_prim=no"
    new_cluster=""
    if [ "${leader}" = "true" ] && [ ! -f "/opt/rancher/initialized" ]; then
        new_cluster="--wsrep-new-cluster"
        touch /opt/rancher/initialized
    fi

    ## Incase this is the initial startup.
    if [ "${leader}" = "false" ] && [ ! -f "/opt/rancher/firstbooted" ]; then
        random_sleep
        touch /opt/rancher/firstbooted
    fi

    set -- mysqld ${new_cluster} "${connect_string}"
fi 

exec /docker-entrypoint.sh "$@"
