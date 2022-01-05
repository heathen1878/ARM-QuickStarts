# App Service - Custom Domain - Certificate

This solution consumes the certificate generated / renewed by the [Lets Encrypt automation solution](https://github.com/heathen1878/posh-acme-azure-example#readme).

The following parameters are mandatory:

* Location
* RBAC
* Host Name - custom domain name
* Key Vault Resource Id
* Key Vault Certificate Secret name

```json
"parameters": {
        "location": {
            "value": "North Europe"
        },
        "RBAC": {
            "value": [
                {
                    "roleId": "acdd72a7-3385-48ef-bd42-f606fba81ae7",
                    "principalId": "00000000-0000-0000-0000-000000000000"
                }
            ]
        },
        "hostName": {
            "value": "www.domain.com"
        },
        "keyVault_Id": {
            "value": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegroupname/providers/Microsoft.KeyVault/vaults/keyvaultname"
        },
        "secret_Name": {
            "value": "certificate-name"
        }
    }
```





