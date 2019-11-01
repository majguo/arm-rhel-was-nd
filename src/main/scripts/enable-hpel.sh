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
wasProfilePath=$1 #WAS ND profile path
wasServerName=$2 #WAS ND server name
outLogPath=$3 #Log output path
logViewerSvcName=$4 #Name of log viewer service

# Enable HPEL service
cp enable-hpel.py enable-hpel.py.bak
sed -i "s/\${WAS_SERVER_NAME}/${wasServerName}/g" enable-hpel.py
"$wasProfilePath"/bin/wsadmin.sh -lang jython -f enable-hpel.py

# Add systemd unit file for log viewer service
cat <<EOF > /etc/systemd/system/${logViewerSvcName}.service
[Unit]
Description=IBM WebSphere Application Log Viewer
[Service]
Type=simple
ExecStart=${wasProfilePath}/bin/logViewer.sh -outLog ${outLogPath} -resumable -resume -format json -monitor
[Install]
WantedBy=default.target
EOF

# Enable log viewer service
systemctl daemon-reload
systemctl enable "$logViewerSvcName"
