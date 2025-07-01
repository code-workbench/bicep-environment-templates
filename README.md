# Bicep Environment Templates

This repo is designed to provide a collection of bicep templates and composite actions to help facilitate workflows and infrastructure-as-code deployments for projects focused on Azure Government and the broader mack-bytes-government organization.  These artifacts are published here to make it easy to consume and utilize these as part of your own deployments.  

The key elements in this repo are:

- **Bicep Modules:** These bicep modules provide "lego bricks" for assembling your infrastructure-as-code" deployments and are built to meet the specification of Government customers and impact levels.  
- **Developer Scripts:** These scripts are designed to include common operations that are designed to provide "easy-buttons" to prevent having to lookup what each of these steps is, and how they work.  
- **Github Composite Actions:** These are composite actions designed specifically to be atomic and reusable in a variety of situations.  The intention being that these are common steps to prevent technical debt, improve quality, and increase stability by leveraging a single code instance.  
- **Packer VM Configuration:** These are packer images for specific virtual machines that are designed to support specific use-cases.  

## Bicep Modules

The following are the bicep modules that have been created in this repository:

- data science virtual machine: 
- key vault: 
- network:
- registry: 
- storage accounts:
- NSGs for Subnets: 
- Virtual machines: 

## Bicep Environments:

The following are environment templates designed to support common configurations.  

### Deploying an Environment

First this deployment requires a resource group and a virtual network to work with.  If those do not exist, run the following to stand them up.

```bash
az cloud set --name AzureUSGovernment
```
The following is the command to login.  
```bash
az login
```

Now that you have logged into azure you can use the following to deploy the code.  

```bash
RESOURCE_GROUP_NAME="test-rg"
VNET_NAME="test-vnet"
LOCATION="usgovvirginia"
SUBNET_NAME="default"

# Create the resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create the virtual network
az network vnet create --name $VNET_NAME --resource-group $RESOURCE_GROUP_NAME --subnet-name $SUBNET_NAME
```

From here, you can deploy any template you want, for example, here's the machine learning environment template:

```bash
PROJECT_PREFIX="bicep"
ENV_PREFIX="dev"
DEFAULT_TAG_NAME="Environment"
DEFAULT_TAG_VALUE="machine-learning-bicep"

az deployment group create --resource-group $RESOURCE_GROUP_NAME --template-file ./environments/basic.bicep --parameters project_prefix=$PROJECT_PREFIX env_prefix=$ENV_PREFIX location=$LOCATION existing_network_name=$VNET_NAME default_tag_name=$DEFAULT_TAG_NAME default_tag_value=$DEFAULT_TAG_VALUE
```

## Deploying Individual Developer Virtual Machines

As part of this you can deploy a Virtual Machines that are attached to a vnet with this template.  Specifically this template enables publishing Data Science Virtual Machines because of the developer tools. The following steps can be used to deploy:

```bash
RESOURCE_GROUP_NAME="test-rg" # Existing resource group to deploy the machine to.  
LOCATION="" # Region for deployment
SUBNET_ID="" # The Resource ID of the subnet to attach the VM to.

# Virtual Machine Details:
VM_NAME="" # Name of the Virtual Machine
ADMIN_USER_NAME="" # Admin Username for the machine
DEFAULT_TAG_NAME="" # A tag name to attach.
DEFAULT_TAG_VALUE="" # The value of the tag.

az deployment group create --resource-group $RESOURCE_GROUP_NAME --template-file ./modules/virtual-machine.bicep --parameters vm_name=$VM_NAME subnet_id=$SUBNET_ID data_science_vm_type=$MACHINE_TYPE admin_user_name=$ADMIN_USER_NAME default_tag_name=$DEFAULT_TAG_NAME default_tag_value=$DEFAULT_TAG_VALUE
```

## Developer Scripts

For this repo there are several developer scripts designed to provide support for common operations. They are outlined below:

### publish-bicep-to-registry.sh

This script will publish all bicep files in a directory up to a container registry.  The goal being to facilitate using these scripts from a container registry internally.  

The benefit of this being that you could take this repo, clone it and move it into a restricted environment.  

For more on bicep templates that can be leveraged from registries, find documentation [here](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/quickstart-private-module-registry?tabs=azure-cli).

The script is run by using the following:

```bash
FOLDER_PATH=""
IMAGE_TAG="" # Latest or a specific version
REGISTRY_NAME="" # The name of the registry to push to, likely "***.azurecr.us"
IMAGE_PREFIX="" # Anything you want to name the repository between the registry name and the file name.

bash ./developer-scripts/publish-bicep-to-registry.sh --folder-path $FOLDER_PATH --image-tag $IMAGE_TAG --registry-name $REGISTRY_NAME --image-prefix $IMAGE_PREFIX$
```

## Github Composite Actions:

Implemented in this repo are composite actions that you can leverage as part of your github workflows.  The intention being that we provide a common reusable implementation to make life easier and improve stability.  

All of the composite actions can be found in the "composite-actions" directory.  Below is a sample of how to implement them in your own repo:

```
name: test get agent details
on: 
    workflow-dispatch:

jobs:
  test-get-agent-details:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - uses: mack-bytes-government/bicep-environment-templates/composite-actions/get-agent-details@get-agent-details-latest
```

When identifying the "@" value at the end of the line, you have 2 options:

1. You can use "@main" which will always pull the "main" branch version that is available.  That does mean that you will always being using the latest, and if the parameter signature changes, it wil fail.  
2. You can pin to the "latest" of that action file, by using "@__ACTION_NAME__-latest" (for example: get-agent-details-latest).  This is predominantly used for testing.  
3. You can pin to a specific version number, by using "@__ACTION_NAME__-__VERSION_NUMBER__" (for example: get-agent-details-1.0.0), this will pin you to a specific release.  

## Packer Virtual Machine Configuration:

This repo contains virtual machine configurations to support new environments that are created.  The following are the key virtual machine configuration files in this repo:

- **[kubernetes-linux-jumpbox.pkr.hcl](./vm-images/kubernetes-linux-jumpbox.pkr.hcl): This machine provides a jumpbox for accessing and working with kubernetes clusters.  

### Build packer vm images:

To build a VM image in your Azure subscription using the `./vm-images/kubernetes-linux-jumpbox.pkr.hcl` file, follow these steps:

1. **Install Packer**  
  Make sure you have [Packer](https://developer.hashicorp.com/packer/install) installed on your machine. You can run this script to install it or use the repo task by hitting F1.

  ```bash
  bash ./scripts/install-packer.sh
  ```

2. **Authenticate with Azure**  
  Ensure you are logged in to Azure CLI and have the necessary permissions:
  ```bash
  az cloud set --name AzureUSGovernment
  az login --use-device-code
  az account set --subscription "<your-subscription-id>"
  ```

3. **Validate the Packer Template**  
  Run the following command to validate your Packer template:
  ```bash
  packer validate ./vm-images/kubernetes-linux-jumpbox.pkr.hcl
  ```

4. **Build the Image**  
  Execute the build command:
  ```bash
  packer build -var "subscription_id=<your-subscription-id>" -var "location=<your-location>" ./vm-images/kubernetes-linux-jumpbox.pkr.hcl
  ```

5. **Locate the Image in Azure**  
  After the build completes, the image will be available in the resource group and location specified in your Packer template.

> For more details, see the [Packer Azure Builder documentation](https://developer.hashicorp.com/packer/plugins/builders/azure).
