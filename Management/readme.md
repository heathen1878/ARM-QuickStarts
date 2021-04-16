# Azure Management deployment

[Home](../readme.md)

Deploys management resources within a resource group; this could be within its own Azure Subscription or in within a shared Azure subscription.

The resources you can expect to see are:

* Resource Group
  * RBAC
  * Tags
  * Azure Policy
* Log Analytics Workspace
* Automation Account

For the linked templates to work, the linked template need to be publicly accessible e.g. in a storage account; these templates can be secured using a storage account key a.k.a Shared Access Signature.