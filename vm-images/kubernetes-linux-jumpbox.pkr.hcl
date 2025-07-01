variable "subscription_id" {
  type    = string
  default = ""
  description = "Azure Subscription ID"
}

variable "location" {
  type    = string
  default = "usgovvirginia"
  description = "Azure region for the image"
}

variable "managed_images_rg_name" {
  type    = string
  default = "packer-vm-images"
  description = "Resource group name for the Packer VM images"
}

variable "managed_image_name" {
  type    = string
  default = "ubuntu2404-aks-linux-jumpbox-image"
  description = "Name of the managed image to be created by Packer"
}

packer {
  required_plugins {
    azure = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

source "azure-arm" "ubuntu2404" {
  subscription_id        = var.subscription_id
  cloud_environment_name = "AzureUSGovernmentCloud"
  location               = var.location

  managed_image_resource_group_name = var.managed_images_rg_name
  managed_image_name                = var.managed_image_name

  vm_size           = "Standard_DS1_v2"
  os_type           = "Linux"
  image_publisher   = "Canonical"
  image_offer       = "ubuntu-24_04-lts"
  image_sku         = "server"
  image_version     = "latest"

  azure_tags = {
    environment = "image-library"
  }

  use_azure_cli_auth = true
}

build {
  sources = ["source.azure-arm.ubuntu2404"]

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "echo 'Running the initial setup upgrade...'",
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
        "echo 'Installing kubectl...'",
        "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"",
        "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",
        "kubectl version --client"
    ]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
        "echo 'Install Azure CLI...'",
        "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    ]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
        "echo 'Installing Helm...'",
        "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3",
        "chmod 700 get_helm.sh",
        "./get_helm.sh"
    ]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
        "echo 'Installing k9s...'",
        "wget https://github.com/derailed/k9s/releases/download/v0.50.6/k9s_linux_amd64.deb",
        "sudo apt install ./k9s_linux_amd64.deb",
        "k9s version",
        "rm k9s_linux_amd64.deb"
    ]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
        "echo 'Installing Terraform...'",
        "wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg",
        "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
        "sudo apt update && sudo apt install terraform"
    ]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
        "echo 'Installing RegClient...'",
        "curl -L https://github.com/regclient/regclient/releases/latest/download/regctl-linux-amd64 >regctl",
        "chmod 755 regctl"
    ]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
        "echo 'Installing Docker...'",
        "sudo apt-get install ca-certificates curl",
        "sudo install -m 0755 -d /etc/apt/keyrings",
        "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
        "sudo chmod a+r /etc/apt/keyrings/docker.asc",
        "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
        "sudo apt-get update"
    ]
  }
}