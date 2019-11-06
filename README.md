# Deploy a RHEL 7.4 VM on Azure with IBM WebSphere Application Server ND Traditional V9.0.5.1 pre-installed

## Prerequisites
 - Register an [Azure subscription](https://azure.microsoft.com/en-us/)
 - Register an [IBM id](https://idaas.iam.ibm.com/idaas/mtfim/sps/authsvc?PolicyId=urn:ibm:security:authentication:asf:basicldapuser)
 - Download [IBM Installation Manager Installation Kit V1.9](https://www-945.ibm.com/support/fixcentral/swg/downloadFixes?parent=ibm%7ERational&product=ibm/Rational/IBM+Installation+Manager&release=1.9.0.0&platform=Linux&function=fixId&fixids=1.9.0.0-IBMIM-LINUX-X86_64-20190715_0328&useReleaseAsTarget=true&includeRequisites=1&includeSupersedes=0&downloadMethod=http)
 - Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
 - Install [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6)
 - Install Maven

 ## Steps of deployment
 1. Checkout [azure-javaee-iaas](https://github.com/Azure/azure-javaee-iaas)
    - change to directory hosting the repo project & run `mvn clean install`
 2. Checkout [azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates) under the specified parent directory
 3. Checkout this repo under the same parent directory and change to directory hosting the repo project
 4. Build the project by replacing all placeholder `${<place_holder>}` with valid values
    - if you want to connect DB2 Server to your WebSphere server, provide valid DNS name/IP address, port number, database name, user name & password of a running & accessible DB2 server for parameters `db2ServerName`, `db2ServerPortNumber`, `db2DBName`, `db2DBUserName` & `db2DBUserPwd`
      ```
      mvn -Dgit.repo=<repo_user> -Dgit.tag=<repo_tag> -DibmUserId=<ibmUserId> -DibmUserPwd=<ibmUserPwd> -DadminUser=<adminUser> -DadminPwd=<adminPwd> -DvmAdminId=<vmAdminId> -DvmAdminPwd=<vmAdminPwd> -DdnsLabelPrefix=<dnsLabelPrefix> -DvirtualMachineName=<virtualMachineName> -DvirtualNetworkName=<virtualNetworkName> -DaddressPrefix=<addressPrefix> -DsubnetName=<subnetName> -DsubnetAddressPrefix=<subnetAddressPrefix> -DconnectToDB2Server=true -Ddb2ServerName=<db2ServerName> -Ddb2ServerPortNumber=<db2ServerPortNumber> -Ddb2DBName=<db2DBName> -Ddb2DBUserName=<db2DBUserName> -Ddb2DBUserPwd=<db2DBUserPwd> -Dtest.args="-Test All" -Ptemplate-validation-tests clean install
      ```
    - otherwise, assign empty strings `""` to them
      ```
      mvn -Dgit.repo=<repo_user> -Dgit.tag=<repo_tag> -DibmUserId=<ibmUserId> -DibmUserPwd=<ibmUserPwd> -DadminUser=<adminUser> -DadminPwd=<adminPwd> -DvmAdminId=<vmAdminId> -DvmAdminPwd=<vmAdminPwd> -DdnsLabelPrefix=<dnsLabelPrefix> -DvirtualMachineName=<virtualMachineName> -DvirtualNetworkName=<virtualNetworkName> -DaddressPrefix=<addressPrefix> -DsubnetName=<subnetName> -DsubnetAddressPrefix=<subnetAddressPrefix> -DconnectToDB2Server=false -Dtest.args="-Test All" -Ptemplate-validation-tests clean install
      ```
 5. Change to `.\target\scripts` directory
 6. Using `deploy.azcli` to deploy
    ```
    deploy.azcli -n <deploymentName> -f <installKitFile> -i <subscriptionId> -g <resourceGroupName> -l <resourceGroupLocation>
    ```

## After deployment
- If you check the resource group in [azure portal](https://portal.azure.com/), you will see related resources created
- Open VM resource blade and copy its DNS name, then open IBM WebSphere Integrated Solutions Console for further administration by browsing https://<dns_name>:9043/ibm/console
- The WebSphere server will be automatically started whenever the virtual machine is rebooted. In case you want to mannually stop/start/restart the server, using the following commands:
  ```
  systemctl stop websphere    # stop WebSphere server
  systemctl start websphere   # start WebSphere server
  systemctl restart websphere # restart WebSphere server
  ```
