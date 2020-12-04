#!/bin/sh

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

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
