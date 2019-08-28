# create a resource group for the whole week

$resourceGroup= Read-Host "Insert Resource Group name"
$location="westeurope"
az group create -l $location -n $resourceGroup

# deploy a basic webapp

az group deployment create --name BasicWebapp --resource-group $resourceGroup --template-file /home/lucas.ducau/Globant%20Azure%20Academy/5taAcademy/lucasducau/week-6/basic-webapp/azuredeploy.json --parameters /home/lucas.ducau/Globant%20Azure%20Academy/5taAcademy/lucasducau/week-6/basic-webapp/azuredeploy.parameters.json  


# Deploy a Linux VM

az group deployment create --name LinuxVM --resource-group $resourceGroup --template-file /home/lucas.ducau/Globant%20Azure%20Academy/5taAcademy/lucasducau/week-6/linux-vm/template.json

# Deploy a Scale Set

az group deployment create --name ScaleSetLucas --resource-group $resourceGroup --template-file /home/lucas.ducau/Globant%20Azure%20Academy/5taAcademy/lucasducau/week-6/scale-set/template2.json # el 2 es mas cheto




