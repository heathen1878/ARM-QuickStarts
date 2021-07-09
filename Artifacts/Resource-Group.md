# Resource Group ARM template

[Home](../readme.md)

The Resource-Group.json deploys a resource group taking the following parameters. 

The parameter: company is used for naming convention, if parameter: company is omitted then the naming convention is adjusted using the variable: resourceGroupPrefix

e.g. take into consideration the following parameter file

```json
...
"parameters": {
        "Company":{
            "value": "Dom"
        },
        "environment": {
            "value": "Demo"
        },
        "location": {
            "value": "UK South"
        },
        "usage": {
            "value": "artifacts"
        },
        "resourceTags":{
            "value": {
                "application": "template specs",
                "businessContact": "Dom Clayton",
                "department": "DevOps",
                "description": "Contains template specs",
                "technicalContact": "Dom Clayton"
            }
        },
        "RBAC": {
            "value": [
                {
                    "roleId": "8e3af657-a8ff-443c-a75c-2fe8c4bcb635",
                    "principalId": "00000000-0000-0000-0000-000000000000" //Some user or group object Id
                }
                {
                    "roleId": "acdd72a7-3385-48ef-bd42-f606fba81ae7",
                    "principalId": "" //Some user or group object Id
                }
            ]
        },
        "DedicatedSubscription": {
            "value": "No"
        }
    }
```
The resource group would be: RG-DOM-DEMO-ARTIFACTS-UKSOUTH whereas if the company is omitted then the Resource Group is named RG-DEMO-ARTIFACTS-UKSOUTH.

The parameter: DedicatedSubscription is used to determine whether a subscription level Azure Policy should be assigned. This version of the template simply assign a policy which restricts the location where resource group metadata can reside.

```json
{
            "condition": "[equals(parameters('DedicatedSubscription'), 'Yes')]",
            "type": "Microsoft.Authorization/policyAssignments",
            "apiVersion": "2019-09-01",
            "name": "[guid(variables('rgLocationPolicyId'), parameters('Location'))]",
            "dependsOn":[
                "[resourceId('Microsoft.Resources/resourceGroups', variables('resourceGroupName'))]"
            ],
            "properties":{
                "displayName": "[concat('Allowed Locations for Resource Groups: ', parameters('location'))]",
                "policyDefinitionId": "[variables('rgLocationPolicyId')]",
                "parameters":{
                "listOfAllowedLocations": {
                        "value": "[variables('allowedLocations')]"
                    }
                }
            }
        }
```

