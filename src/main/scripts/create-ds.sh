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
wasRootPath=$1 #Root path of WebSphere
wasProfileName=$2 #WAS ND profile name
wasServerName=$3 #WAS ND server name
db2ServerName=$4 #Host name/IP address of IBM DB2 Server
db2ServerPortNumber=$5 #Server port number of IBM DB2 Server
db2DBName=$6 #Database name of IBM DB2 Server
db2DBUserName=$7 #Database user name of IBM DB2 Server
db2DBUserPwd=$8 #Database user password of IBM DB2 Server
db2DSJndiName=${9:-jdbc/Sample}

# Variables
jdbcDriverPath="$wasRootPath"/db2/java

# Copy jdbc drivers
mkdir -p "$jdbcDriverPath"
find "$wasRootPath" -name "db2jcc*.jar" | xargs -I{} cp {} "$jdbcDriverPath"
jdbcDriverPath=$(realpath "$jdbcDriverPath")

# Get jython file template & replace placeholder strings with user-input parameters
cp create-ds.py create-ds.py.bak
sed -i "s/\${WAS_SERVER_NAME}/${wasServerName}/g" create-ds.py
sed -i "s#\${DB2UNIVERSAL_JDBC_DRIVER_PATH}#${jdbcDriverPath}#g" create-ds.py
sed -i "s/\${DB2_DATABASE_USER_NAME}/${db2DBUserName}/g" create-ds.py
sed -i "s/\${DB2_DATABASE_USER_PASSWORD}/${db2DBUserPwd}/g" create-ds.py
sed -i "s/\${DB2_DATABASE_NAME}/${db2DBName}/g" create-ds.py
sed -i "s#\${DB2_DATASOURCE_JNDI_NAME}#${db2DSJndiName}#g" create-ds.py
sed -i "s/\${DB2_SERVER_NAME}/${db2ServerName}/g" create-ds.py
sed -i "s/\${PORT_NUMBER}/${db2ServerPortNumber}/g" create-ds.py

# Create JDBC provider and data source using jython file
"$wasRootPath"/profiles/${wasProfileName}/bin/wsadmin.sh -lang jython -f create-ds.py
