#!/bin/bash

cp /start_galera.sh /giddyup /opt/rancher/
/giddyup service wait scale

exec /confd --backend=rancher --prefix=/2015-07-25
