#!/bin/sh
# Parameters
outLogPath=$1 #Log output path
cloudId=$2 #Cloud ID of Elasticsearch Service on Elastic Cloud
cloudAuthUser=$3 #User name of Elasticsearch Service on Elastic Cloud
cloudAuthPwd=$4 #Password of Elasticsearch Service on Elastic Cloud

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
  json.message_key: message
  json.keys_under_root: true
  json.add_error_key: true

processors:
- add_cloud_metadata: ~

cloud.id: ${cloudId}
cloud.auth: ${cloudAuthUser}:${cloudAuthPwd}
EOF

# Enable & start filebeat
systemctl daemon-reload
systemctl enable filebeat
systemctl start filebeat
