#!/bin/sh

#      Copyright (c) Microsoft Corporation.
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#           http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

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
