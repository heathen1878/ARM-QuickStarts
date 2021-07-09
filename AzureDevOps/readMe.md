# Azure DevOps

[Home](../readme.md)

The PowerShell script in this folder can be used to grant the correct access permissons to an AAD tenant and subscription. The script takes no parameters - maybe it should - and simply creates a application registration and service principal in Azure AD and finally spits out an Service Principal Id, Service Principal Key, and Azure AD tenant Id. This can be used within Azure DevOps to create a Service Connection. You'll also need the subscription Id too.

![Service Connection](https://stdevt4z3f7au4f3xe.blob.core.windows.net/images/ServiceConnection.PNG)
