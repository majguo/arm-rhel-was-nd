#!/bin/sh
# Parameters
websphereSrv=$1 #System service name for starting/stopping WebSphere server
wasRootPath=$2 #Root path of WebSphere
wasProfileName=$3 #WAS ND profile name
wasServerName=$4 #WAS ND server name
db2ServerName=$5 #Host name/IP address of IBM DB2 Server
db2ServerPortNumber=$6 #Server port number of IBM DB2 Server
db2DBName=$7 #Database name of IBM DB2 Server
db2DBUserName=$8 #Database user name of IBM DB2 Server
db2DBUserPwd=$9 #Database user password of IBM DB2 Server
scriptLocation=${10} #Script location ends in a trailing slash

# Variables
createDSFileUri="$scriptLocation"db2/create-ds.py
createDSFileName=create-ds.py
jdbcDriverPath="$wasRootPath"/db2/java

# Copy jdbc drivers
mkdir -p "$jdbcDriverPath"
find "$wasRootPath" -name "db2jcc*.jar" | xargs -I{} cp {} "$jdbcDriverPath"
jdbcDriverPath=$(realpath "$jdbcDriverPath")

# Get jython file template & replace placeholder strings with user-input parameters
wget -O "$createDSFileName" "$createDSFileUri"
sed -i "s/\${WAS_SERVER_NAME}/${wasServerName}/g" "$createDSFileName"
sed -i "s#\${DB2UNIVERSAL_JDBC_DRIVER_PATH}#${jdbcDriverPath}#g" "$createDSFileName"
sed -i "s/\${DB2_DATABASE_USER_NAME}/${db2DBUserName}/g" "$createDSFileName"
sed -i "s/\${DB2_DATABASE_USER_PASSWORD}/${db2DBUserPwd}/g" "$createDSFileName"
sed -i "s/\${DB2_DATABASE_NAME}/${db2DBName}/g" "$createDSFileName"
sed -i "s/\${DB2_SERVER_NAME}/${db2ServerName}/g" "$createDSFileName"
sed -i "s/\${PORT_NUMBER}/${db2ServerPortNumber}/g" "$createDSFileName"

# Create JDBC provider and data source using jython file
"$wasRootPath"/bin/wsadmin.sh -lang jython -f "$createDSFileName"

# Restart server
systemctl restart "$websphereSrv"
