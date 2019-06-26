break
# #############################################################################
# Azure RBAC and Security
# AUTHOR:  Tim Warner
# EMAIL: timothy-warner@pluralsight.com
# #############################################################################

#region RBAC in the CLI
az login

az account list

az account set --subscription '150-Jan-19'

az role -h

az role definition list --output table
#endregion

#region RBAC PowerShell
Login-AzureRmAccount

$subscriptionId = 
    (Get-AzureRmSubscription |
     Out-GridView `
        -Title "Select an Azure Subscription ..." `
        -PassThru).SubscriptionId

Select-AzureRmSubscription `
    -SubscriptionId $subscriptionId

$rgName =
    (Get-AzureRmResourceGroup |
     Out-GridView `
        -Title "Select an Azure Resource Group ..." `
        -PassThru).ResourceGroupName

$stName = 
    (Get-AzureRmStorageAccount |
    Out-GridView `
        -Title "Select an Azure storage account..." `
        -PassThru).StorageAccountName

Set-AzureRmCurrentStorageAccount -ResourceGroupName $rgName -Name $stName

# list all roles
Get-AzureRmRoleDefinition | Format-Table -Property Name, Description

# list all actions of a role
Get-AzureRmRoleDefinition -Name Contributor | Format-List -Property Actions, NotActions

# List role assignments at particular scope
Get-AzureRmRoleAssignment -ResourceGroupName 'AzureTraining' | Format-List -Property DisplayName, RoleDefinitionName, Scope

# List roles assigned to a user
$useremail = ''
Get-AzureRmRoleAssignment -SignInName $useremail | Format-List -Property DisplayName, RoleDefinitionName, Scope
#endregion

#region PowerShell - Activity Logs
Get-AzureRmLog -ResourceGroup 'AzureTraining'

# Look for entries from last 5 days
Get-AzureRmLog -ResourceGroup 'AzureTraining' -StartTime (Get-Date).AddDays(-5)

# Look for failed operations
Get-AzureRmLog -ResourceGroup 'AzureTraining' -Status Failed

((Get-AzureRmLog -Status Failed -ResourceGroup 'AzureTraining' -DetailedOutput).Properties[1].Content["statusMessage"] | ConvertFrom-Json).error

# Azure CLI
azure group log show 'AzureTraining' --output json
#endregion




