#!/bin/bash

sudo $SPARK_HOME/sbin/start-master.sh
sudo $SPARK_HOME/sbin/start-worker.sh spark://${HOSTNAME}:7077
