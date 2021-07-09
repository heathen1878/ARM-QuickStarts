# Azure DevOps

[Home](../readme.md)

The PowerShell script: Azure-DevOps-Service-Connection.ps1 creates an application registration and service principal in Azure AD, then spits out the Service Principal Id, Service Principal Key, Azure AD tenant Id, and Subscription Id of the subscription you select.

You can specify your own service principal name or accept the default PipelineDeployment e.g. 

Azure-DevOps-Service-Connection.ps1

or 

Azure-DevOps-Service-Connection.ps1 -servicePrincipalName Something

You can use these to populate the Service Connection information within Azure 
DevOps.  

![Service Principal](https://stdevt4z3f7au4f3xe.blob.core.windows.net/images/CreateServicePrincipal.PNG)

This can be used within Azure DevOps to create a Service Connection. You'll also need the subscription Id too.

![Service Connection](https://stdevt4z3f7au4f3xe.blob.core.windows.net/images/ServiceConnection.PNG)

I've added several API permissions to the service principal which allows pipeline deployment to create another service principal - this is useful when deploying an Azure Automation RunAs Account. 

![API Permissions](https://stdevt4z3f7au4f3xe.blob.core.windows.net/images/APIPermissions.PNG)

The service principal is also granted owner on the subscription to enable the pipeline deployment to assign RBAC.

![Service Principal RBAC](https://stdevt4z3f7au4f3xe.blob.core.windows.net/images/SPRBAC.PNG)
