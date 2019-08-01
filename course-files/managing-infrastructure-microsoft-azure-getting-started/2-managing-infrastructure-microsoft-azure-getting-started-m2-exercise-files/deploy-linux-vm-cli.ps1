break
# #############################################################################
# Deploy Linux VMs to Azure with Azure CLI v2.0
# Repo: https://github.com/timothywarner/linux
# AUTHOR:  Tim Warner
# EMAIL: timothy-warner@pluralsight.com
# TWITTER: @TechTrainerTim
# WEB: timw.info
# #############################################################################

ssh-keygen -t rsa -b 2048 -C "tim@vm-azuretraining-704" -f c:/users/tim/.ssh/id_rsa -N myP@$$w0rd1

az

az login

az group create -n myResourceGroup -l eastus

az vm create --image credativ:Debian:8:latest --admin-username tim --ssh-key-value C:/users/tim/.ssh/id_rsa.pub --public-ip-address-dns-name vm-azuretraining-704 --resource-group myResourceGroup --location eastus --name vm-azuretraining-704

ssh tim@vm-azuretraining-704.eastus.cloudapp.azure.com