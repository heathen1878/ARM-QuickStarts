# Azure Connectivity deployment

[Home](../readme.md)

Deploys connectivity resources within a resource group; this could be within its own Azure Subscription or in within a shared Azure subscription.

The resources you can expect to see are:

* Resource Group
  * RBAC
  * Tags
  * Azure Policy
* Network Watcher
* Virtual Network
* VPN Gateway with GatewaySubnet within the above Virtual Network
* Azure Firewall with FirewallSubnet within the above Virtual Network

For the linked templates to work, the linked template need to be publicly accessible e.g. in a storage account; these templates can be secured using a storage account key a.k.a Shared Access Signature.
