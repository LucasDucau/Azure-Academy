
$resourceGroup = Read-Host "Resource Group name"
$location = Read-Host "Location"


az group create -n $resourceGroup -l $location


az group deployment create --resource-group $resourceGroup --template-file template.json










# az vm extension set --publisher Microsoft.Azure.Extensions --version 2.0 --name CustomScript --vm-name vm1-vm --resource-group test1 --settings '{"commandToExecute":"apt-get -y update && git clone https://github.com/docker/docker-install.git && cd docker-install && sh install.sh"}' 

