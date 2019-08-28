$resourceGroup= Read-Host "Insert Resource Group name"
$location="westeurope"
az group create -l $location -n $resourceGroup


az group deployment create `
--name WebAppwithslots `
--resource-group $resourceGroup `
--template-file template.json `
--parameters parameters.json `

