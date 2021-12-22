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

# Get tWAS installation properties
source /datadrive/virtualimage.properties

# Check whether the user is entitled or not
while [ ! -f "$WAS_LOG_PATH" ]
do
    sleep 5
done

isDone=false
while [ $isDone = false ]
do
    result=`(tail -n1) <$WAS_LOG_PATH`
    if [[ $result = $ENTITLED ]] || [[ $result = $UNENTITLED ]] || [[ $result = $UNDEFINED ]]; then
        isDone=true
    else
        sleep 5
    fi
done

# Remove cloud-init artifacts and logs
cloud-init clean --logs

# Terminate the process for the un-entitled or undefined user
if [ ${result} != $ENTITLED ]; then
    if [ ${result} = $UNENTITLED ]; then
        echo "The provided IBM ID does not have entitlement to install WebSphere Application Server. Please contact the primary or secondary contacts for your IBM Passport Advantage site to grant you access or follow steps at IBM eCustomer Care (https://ibm.biz/IBMidEntitlement) for further assistance."
    else
        echo "No WebSphere Application Server installation packages were found. This is likely due to a temporary issue with the installation repository. Try again and open an IBM Support issue if the problem persists."
    fi
    exit 1
fi

# Check required parameters
if [ "$2" == "" ]; then 
  echo "Usage:"
  echo "  ./install.sh [adminUserName] [adminPassword]"
  exit 1
fi
adminUserName=$1
adminPassword=$2

# Open ports by adding iptables rules
firewall-cmd --zone=public --add-port=9060/tcp --permanent
firewall-cmd --zone=public --add-port=9080/tcp --permanent
firewall-cmd --zone=public --add-port=9043/tcp --permanent
firewall-cmd --zone=public --add-port=9443/tcp --permanent
firewall-cmd --reload

# Create standalone application profile
${WAS_BASE_INSTALL_DIRECTORY}/bin/manageprofiles.sh -create -profileName AppSrv1 -templatePath ${WAS_BASE_INSTALL_DIRECTORY}/profileTemplates/default \
    -hostName $(hostname) -nodeName $(hostname)Node01 -enableAdminSecurity true -adminUserName "$adminUserName" -adminPassword "$adminPassword"

# Add credentials to "soap.client.props" so they can be read by relative commands if required
soapClientProps=${WAS_BASE_INSTALL_DIRECTORY}/profiles/AppSrv1/properties/soap.client.props
sed -i "s/com.ibm.SOAP.securityEnabled=false/com.ibm.SOAP.securityEnabled=true/g" "$soapClientProps"
sed -i "s/com.ibm.SOAP.loginUserid=/com.ibm.SOAP.loginUserid=${adminUserName}/g" "$soapClientProps"
sed -i "s/com.ibm.SOAP.loginPassword=/com.ibm.SOAP.loginPassword=${adminPassword}/g" "$soapClientProps"
# Encrypt com.ibm.SOAP.loginPassword
${WAS_BASE_INSTALL_DIRECTORY}/profiles/AppSrv1/bin/PropFilePasswordEncoder.sh "$soapClientProps" com.ibm.SOAP.loginPassword

# Create and start server
${WAS_BASE_INSTALL_DIRECTORY}/profiles/AppSrv1/bin/startServer.sh server1
