

$resourceGroup = Read-Host "Resource Group name"
$location = Read-Host "Location"
$name = Read-Host "Deployment Name"



az group create -n $resourceGroup -l $location


 az group deployment create `
    --name $name `
    --resource-group $resourceGroup `
    --template-file template.json `


$outputqq = az group deployment show -g $resourceGroup -n $name --query properties.outputs.dnsName.value

echo $outputqq > /home/lucas/Azure-Academy/vms-with-docker/dnsName


python3 ./trim_filename.py ./dnsName


ansible-playbook -i ./dnsName ./playbook.yml








# az vm extension set --publisher Microsoft.Azure.Extensions --version 2.0 --name CustomScript --vm-name vm1-vm --resource-group test1 --settings '{"commandToExecute":"apt-get -y update && git clone https://github.com/docker/docker-install.git && cd docker-install && sh install.sh"}' 

