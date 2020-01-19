#!/bin/sh
# Parameters
outLogPath=$1 #Log output path
logStashServerName=$2 #Host name/IP address of LogStash Server
logStashServerPortNumber=$3 #Port number of LogStash Server

# TODO: Install Filebeat
echo "Log output path is ${outLogPath}"
echo "Host name/IP address of LogStash Server is ${logStashServerName}"
echo "Port number of LogStash Server is ${logStashServerPortNumber}"