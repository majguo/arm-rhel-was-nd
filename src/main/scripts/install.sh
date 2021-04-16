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

while getopts "m:c:n:t:d:i:s:j:g:o:k:" opt; do
    case $opt in
        m)
            adminUserName=$OPTARG #User id for admimistrating WebSphere Admin Console
        ;;
        c)
            adminPassword=$OPTARG #Password for administrating WebSphere Admin Console
        ;;
        n)
            db2ServerName=$OPTARG #Host name/IP address of IBM DB2 Server
        ;;
        t)
            db2ServerPortNumber=$OPTARG #Server port number of IBM DB2 Server
        ;;
        d)
            db2DBName=$OPTARG #Database name of IBM DB2 Server
        ;;
        i)
            db2DBUserName=$OPTARG #Database user name of IBM DB2 Server
        ;;
        s)
            db2DBUserPwd=$OPTARG #Database user password of IBM DB2 Server
        ;;
        j)
            db2DSJndiName=$OPTARG #Datasource JNDI name
        ;;
        g)
            cloudId=$OPTARG #Cloud ID of Elasticsearch Service on Elastic Cloud
        ;;
        o)
            cloudAuthUser=$OPTARG #User name of Elasticsearch Service on Elastic Cloud
        ;;
        k)
            cloudAuthPwd=$OPTARG #Password of Elasticsearch Service on Elastic Cloud
        ;;
    esac
done

# Check whether the user is entitled or not
while [ ! -f "/var/log/cloud-init-was.log" ]
do
    echo "waiting for was entitlement check started..."
    sleep 5
done

isDone=false
while [ $isDone = false ]
do
    result=`(tail -n1) </var/log/cloud-init-was.log`
    if [[ $result = Unentitled ]] || [[ $result = Entitled ]]; then
        isDone=true
    else
        echo "waiting for was entitlement check completed..."
        sleep 5
    fi
done
echo $result

# Terminate the process for the un-entitled user
if [ ${result} = Unentitled ]; then
    exit 1
fi

# WebSphere installation directory pre-set by the base image
tWASDirectory=/datadrive/IBM/WebSphere/ND/V9

# Create standalone application profile
${tWASDirectory}/bin/manageprofiles.sh -create -profileName AppSrv1 -templatePath ${tWASDirectory}/profileTemplates/default \
    -hostName $(hostname) -nodeName $(hostname)Node01 -enableAdminSecurity true -adminUserName "$adminUserName" -adminPassword "$adminPassword"

# Add credentials to "soap.client.props" so they can be read by relative commands if required
soapClientProps=${tWASDirectory}/profiles/AppSrv1/properties/soap.client.props
sed -i "s/com.ibm.SOAP.securityEnabled=false/com.ibm.SOAP.securityEnabled=true/g" "$soapClientProps"
sed -i "s/com.ibm.SOAP.loginUserid=/com.ibm.SOAP.loginUserid=${adminUserName}/g" "$soapClientProps"
sed -i "s/com.ibm.SOAP.loginPassword=/com.ibm.SOAP.loginPassword=${adminPassword}/g" "$soapClientProps"
# Encrypt com.ibm.SOAP.loginPassword
${tWASDirectory}/profiles/AppSrv1/bin/PropFilePasswordEncoder.sh "$soapClientProps" com.ibm.SOAP.loginPassword

# Create and start server
${tWASDirectory}/profiles/AppSrv1/bin/startServer.sh server1

# Configure JDBC provider and data soruce for IBM DB2 Server if required
if [ ! -z "$db2ServerName" ] && [ ! -z "$db2ServerPortNumber" ] && [ ! -z "$db2DBName" ] && [ ! -z "$db2DBUserName" ] && [ ! -z "$db2DBUserPwd" ]; then
    ./create-ds.sh ${tWASDirectory} AppSrv1 server1 "$db2ServerName" "$db2ServerPortNumber" "$db2DBName" "$db2DBUserName" "$db2DBUserPwd" "$db2DSJndiName"
fi

# Enable HPEL service if required
if [ ! -z "$cloudId" ] && [ ! -z "$cloudAuthUser" ] && [ ! -z "$cloudAuthPwd" ]; then
    ./enable-hpel.sh ${tWASDirectory}/profiles/AppSrv1 server1 ${tWASDirectory}/profiles/AppSrv1/logs/server1/hpelOutput.log was_logviewer
fi

# Add systemd unit file for websphere.service
srvName=websphere
websphereSrv=/etc/systemd/system/${srvName}.service
cat <<EOF > "$websphereSrv"
[Unit]
Description=IBM WebSphere Application Server
[Service]
Type=forking
ExecStart=${tWASDirectory}/profiles/AppSrv1/bin/startServer.sh server1
ExecStop=${tWASDirectory}/profiles/AppSrv1/bin/stopServer.sh server1
PIDFile=${tWASDirectory}/profiles/AppSrv1/logs/server1/server1.pid
SuccessExitStatus=143 0
[Install]
WantedBy=default.target
EOF

# Enable and start websphere service
${tWASDirectory}/profiles/AppSrv1/bin/stopServer.sh server1
systemctl daemon-reload
systemctl enable "$srvName"
systemctl start "$srvName"

# Start HPEL service and distribute log to ELK Stack if required
if [ ! -z "$cloudId" ] && [ ! -z "$cloudAuthUser" ] && [ ! -z "$cloudAuthPwd" ]; then
    systemctl start was_logviewer
    ./setup-filebeat.sh "${tWASDirectory}/profiles/AppSrv1/logs/server1/hpelOutput*.log" "$cloudId" "$cloudAuthUser" "$cloudAuthPwd"
fi

# Open ports by adding iptables rules
firewall-cmd --zone=public --add-port=9060/tcp --permanent
firewall-cmd --zone=public --add-port=9080/tcp --permanent
firewall-cmd --zone=public --add-port=9043/tcp --permanent
firewall-cmd --zone=public --add-port=9443/tcp --permanent
firewall-cmd --reload
