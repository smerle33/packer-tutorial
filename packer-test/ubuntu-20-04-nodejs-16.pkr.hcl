packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

data "amazon-ami" "ubuntu-focal-east" {
  region = "us-east-2"
  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "ubuntu-focal" {
  region         = "us-east-2"
  source_ami     = data.amazon-ami.ubuntu-focal-east.id
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "ubuntu-20-04_AWS_{{timestamp}}_v1.0.0"
}

source "docker" "ubuntu-focal" {
  image  = "ubuntu:focal"
  commit = true
}


build {
  hcp_packer_registry {
    bucket_name = "packer-ubuntu-CB-20-04"
    description = <<EOT
First attempt to create a ubuntu 20.04 LTS with NodeJS 16
    EOT
    labels = {
      "foo-version" = "1.0.0",
      "foo"         = "bar",
    }
  }
  sources = [
    "source.amazon-ebs.ubuntu-focal",
    "source.docker.ubuntu-focal"
  ]

  provisioner "shell" {
    # steps for docker images
    only = ["docker.ubuntu-focal"]

    #adding sudo, curl and bash for docker
    inline = [
      "apt update && apt install -y sudo curl bash",
    ]
  }

  provisioner "shell" {
    # for all
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
    inline = [
      "sudo apt-get update && sudo apt-get upgrade -y",
      //https://github.com/nodesource/distributions/blob/master/README.md  : curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
      "curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
    ]
  }

  post-processor "docker-tag" {
    repository = "packer-cb"
    tags       = ["ubuntu-focal-nodejs"]
    only       = ["docker.ubuntu-focal"]
  }

}
