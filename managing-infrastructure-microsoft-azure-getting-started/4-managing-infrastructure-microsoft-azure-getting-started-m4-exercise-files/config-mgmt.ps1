break
# #############################################################################
# Configuration Management
# AUTHOR:  Tim Warner
# EMAIL: timothy-warner@pluralsight.com
# TWITTER: @TechTrainerTim
# WEB: timw.info
# #############################################################################
 
# Press CTRL+M to expand/collapse regions

#region Connect to Azure
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName '150-Jan-19'
Get-AzureRmSubscription -SubscriptionName '150-Jan-19' | Set-AzureRmContext
Get-Command -CommandType Alias -Module AzureRM*
Get-AzureRmContext
Set-AzureRmCurrentStorageAccount -ResourceGroupName 'AzureTraining' -Name 'azuretrainingstorage2'
#endregion

#region Azure CLI v2.0
az login

az account set --subscription 150-Jan-19

az vm -h

az vm extension -h 

az vm extension image list --output table

az vm extension list --resource-group AzureTraining --vm-name vm-web01
#endregion

#region PowerShell
Get-AzureRmVmImagePublisher -Location WestUS |
Get-AzureRmVMExtensionImageType |
Get-AzureRmVMExtensionImage | Select Type, Version

Get-Command  Set-AzureRM*Extension* -Module AzureRM.Compute

# deploy custom script extension
Start-Process https://raw.githubusercontent.com/neilpeterson/nepeters-azure-templates/master/windows-custom-script-simple/support-scripts/Create-File.ps1

Set-AzureRmVMCustomScriptExtension -ResourceGroupName 'AzureTraining' `
    -VMName 'vm-web01' -Name 'myCustomScript' `
    -FileUri "https://raw.githubusercontent.com/neilpeterson/nepeters-azure-templates/master/windows-custom-script-simple/support-scripts/Create-File.ps1" `
    -Run 'Create-File.ps1' -Location 'South Central US'

# reset local admin password
$cred=Get-Credential
Set-AzureRmVMAccessExtension -ResourceGroupName 'AzureTraining' -VMName 'vm-web01' -Name 'myVMAccess' `
    -Location SouthCentralUS -UserName $cred.GetNetworkCredential().Username `
    -Password $cred.GetNetworkCredential().Password -typeHandlerVersion '2.0'
#endregion
