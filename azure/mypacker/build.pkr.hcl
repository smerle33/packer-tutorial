locals {
  date = formatdate("HHmm", timestamp())
}

source "azure-arm" "ubuntu-lts" {
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  subscription_id = var.azure_subscription_id

  os_type         = "Linux"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_publisher = "canonical"
  image_sku       = "22_04-lts"

  vm_size        = "Standard_B1s"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false

  azure_tags = {
    dept = "JenkinsOSS"
    task = "Image deployment"
  }
}

build {
  source "source.azure-arm.ubuntu-lts" {
    # name               = "jenkins-agent-ubuntu-22.04-amd64"
    location                          = var.azure_region
    managed_image_name                = "jenkins_test_${local.date}"
    managed_image_resource_group_name = "dev-packer-images"
}
