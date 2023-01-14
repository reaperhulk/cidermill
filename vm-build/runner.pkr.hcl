packer {
  required_plugins {
    tart = {
      version = ">= 0.6.1"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

variable "name" {
  type = string
}

source "tart-cli" "tart" {
  vm_base_name = "ghcr.io/cirruslabs/macos-ventura-base:latest"
  vm_name      = "${var.name}"
  cpu_count    = 4
  memory_gb    = 8
  headless     = true
  ssh_password = "admin"
  ssh_username = "admin"
  ssh_timeout  = "120s"
}

build {
  sources = ["source.tart-cli.tart"]

  // Install SSH key DO NOT DELETE
  provisioner "shell" {
    inline = [
      "mkdir ~/.ssh",
    ]
  }
  // Install SSH key DO NOT DELETE
  provisioner "file" {
    source = "runner_authorized_keys"
    destination = "~/.ssh/authorized_keys"
  }
  // Install SSH key DO NOT DELETE
  provisioner "shell" {
    inline = [
      "chmod -R 700 ~/.ssh",
    ]
  }

  // install whatever you want (feel free to delete this)
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "curl https://www.python.org/ftp/python/3.11.1/python-3.11.1-macos11.pkg -o python.pkg",
      "sudo installer -pkg python.pkg -target /",
    ]
  }

  //install rust
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "brew install rustup-init",
      "rustup-init -y",
    ]
  }

  //create a /Users/runner to see if we can trick GH into installing things in the toolcache
  provisioner "shell" {
    inline = [
      "sudo mkdir /Users/runner",
      "sudo chown admin:staff /Users/runner",
      "sudo chmod 750 /Users/runner",
    ]
  }

}
