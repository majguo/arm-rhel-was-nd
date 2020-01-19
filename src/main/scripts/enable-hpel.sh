#!/bin/sh
# Parameters
wasProfilePath=$1 #WAS ND profile path
wasServerName=$2 #WAS ND server name
logStashServerName=$3 #Host name/IP address of LogStash Server
logStashServerPortNumber=$4 #Port number of LogStash Server

# Enable & start HPEL service
cp enable-hpel.py enable-hpel.py.bak
sed -i "s/\${WAS_SERVER_NAME}/${wasServerName}/g" enable-hpel.py
"$wasProfilePath"/bin/wsadmin.sh -lang jython -f enable-hpel.py
${wasProfilePath}/bin/logViewer.sh -outLog ${wasProfilePath}/logs/${wasServerName}/hpelOutput.log -resumable -resume -format json -monitor &

# Add systemd unit file for was_logviewer.service
cat <<EOF > /etc/systemd/system/was_logviewer.service
[Unit]
Description=IBM WebSphere Application Log Viewer
[Service]
Type=simple
ExecStart=${wasProfilePath}/bin/logViewer.sh -outLog ${wasProfilePath}/logs/${wasServerName}/hpelOutput.log -resumable -resume -format json -monitor
[Install]
WantedBy=default.target
EOF

# Enable was_logviewer service
systemctl daemon-reload
systemctl enable was_logviewer

# TODO: Install Filebeat
echo "Host name/IP address of LogStash Server is ${logStashServerName}"
echo "Port number of LogStash Server is ${logStashServerPortNumber}"