$resourceGroup = "rg1273094"
$location = "westeurope"
$deploymentName = "rndname"
$template_file = "template2.json"



#$projectName = Read-Host -Prompt "Enter a project name that is used for generating resource names"
#$location = Read-Host -Prompt "Enter an Azure location (i.e. centralus)"
#$adminUser = Read-Host -Prompt "Enter the SQL server administrator username"
#$adminPassword = Read-Host -Prompt "Enter the SQl server administrator password" -AsSecureString



az group create -l $location -n $resourceGroup

# deploy a basic webapp

az group deployment create -g $resourceGroup -n $deploymentName --template-file $template_file
# --parameters parameters.json
#    --name "dbasd" \
#   --resource-group $resourceGroup \
    
     

