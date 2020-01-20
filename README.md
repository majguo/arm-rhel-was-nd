# Deploy a RHEL 7.4 VM on Azure with IBM WebSphere Application Server ND Traditional V9.0.5 pre-installed

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
    - connect to DB2 Server & Elastic Stack
      ```
      mvn -Dgit.repo=<repo_user> -Dgit.tag=<repo_tag> -DibmUserId=<ibmUserId> -DibmUserPwd=<ibmUserPwd> -DadminUser=<adminUser> -DadminPwd=<adminPwd> -DvmAdminId=<vmAdminId> -DvmAdminPwd=<vmAdminPwd> -DdnsLabelPrefix=<dnsLabelPrefix> -DconnectToDB2Server=true -Ddb2ServerName=<db2ServerName> -Ddb2ServerPortNumber=<db2ServerPortNumber> -Ddb2DBName=<db2DBName> -Ddb2DBUserName=<db2DBUserName> -Ddb2DBUserPwd=<db2DBUserPwd> -Ddb2DSJndiName=<db2DSJndiName> -DconnectToELK=true -DlogStashServerName=<logStashServerName> -DlogStashServerPortNumber=<logStashServerPortNumber> -Dtest.args="-Test All" -Ptemplate-validation-tests clean install
      ```
    - connect to DB2 Server only
      ```
      mvn -Dgit.repo=<repo_user> -Dgit.tag=<repo_tag> -DibmUserId=<ibmUserId> -DibmUserPwd=<ibmUserPwd> -DadminUser=<adminUser> -DadminPwd=<adminPwd> -DvmAdminId=<vmAdminId> -DvmAdminPwd=<vmAdminPwd> -DdnsLabelPrefix=<dnsLabelPrefix> -DconnectToDB2Server=true -Ddb2ServerName=<db2ServerName> -Ddb2ServerPortNumber=<db2ServerPortNumber> -Ddb2DBName=<db2DBName> -Ddb2DBUserName=<db2DBUserName> -Ddb2DBUserPwd=<db2DBUserPwd> -Ddb2DSJndiName=<db2DSJndiName> -DconnectToELK=false -Dtest.args="-Test All" -Ptemplate-validation-tests clean install
      ```
    - connect to Elastic Stack only
      ```
      mvn -Dgit.repo=<repo_user> -Dgit.tag=<repo_tag> -DibmUserId=<ibmUserId> -DibmUserPwd=<ibmUserPwd> -DadminUser=<adminUser> -DadminPwd=<adminPwd> -DvmAdminId=<vmAdminId> -DvmAdminPwd=<vmAdminPwd> -DdnsLabelPrefix=<dnsLabelPrefix> -DconnectToDB2Server=false -DconnectToELK=true -DlogStashServerName=<logStashServerName> -DlogStashServerPortNumber=<logStashServerPortNumber> -Dtest.args="-Test All" -Ptemplate-validation-tests clean install
      ```
    - connect to neither DB2 Server nor Elastic Stack
      ```
      mvn -Dgit.repo=<repo_user> -Dgit.tag=<repo_tag> -DibmUserId=<ibmUserId> -DibmUserPwd=<ibmUserPwd> -DadminUser=<adminUser> -DadminPwd=<adminPwd> -DvmAdminId=<vmAdminId> -DvmAdminPwd=<vmAdminPwd> -DdnsLabelPrefix=<dnsLabelPrefix> -DconnectToDB2Server=false -DconnectToELK=false -Dtest.args="-Test All" -Ptemplate-validation-tests clean install
      ```
 5. Change to `./target/arm` directory
 6. Using `deploy.azcli` to deploy
    ```
    ./deploy.azcli -n <deploymentName> -f <installKitFile> -i <subscriptionId> -g <resourceGroupName> -l <resourceGroupLocation>
    ```

## After deployment
- If you check the resource group in [azure portal](https://portal.azure.com/), you will see related resources created
- To open IBM WebSphere Integrated Solutions Console in browser for further administration:
  - Login to Azure Portal
  - Open the resource group you specified to deploy WebSphere Cluster
  - Navigate to "Deployments > specified_deployment_name > Outputs"
  - Copy value of property `adminSecuredConsole` and browse it with credentials you specified in cluster creation
- The WebSphere server will be automatically started whenever the virtual machine is rebooted. In case you want to mannually stop/start/restart the server, using the following commands:
  ```
  systemctl stop websphere    # stop WebSphere server
  systemctl start websphere   # start WebSphere server
  systemctl restart websphere # restart WebSphere server
  ```
