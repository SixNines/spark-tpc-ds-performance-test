#!/bin/bash

# running as user vscode to simplify permissions
$SPARK_HOME/sbin/start-master.sh
$SPARK_HOME/sbin/start-worker.sh spark://${HOSTNAME}:7077
