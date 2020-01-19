#!/bin/sh
# Parameters
outLogPath=$1 #Log output path
logStashServerName=$2 #Host name/IP address of LogStash Server
logStashServerPortNumber=$3 #Port number of LogStash Server

# Install Filebeat
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat <<EOF > /etc/yum.repos.d/elastic.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
yum install filebeat -y

# Configure Filebeat
mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak
cat <<EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: log
  paths:
    - ${outLogPath}

processors:
- add_cloud_metadata:

output.logstash:
  hosts: ["${logStashServerName}:${logStashServerPortNumber}"]
EOF

# Enable & start filebeat
systemctl daemon-reload
systemctl enable filebeat
systemctl start filebeat
