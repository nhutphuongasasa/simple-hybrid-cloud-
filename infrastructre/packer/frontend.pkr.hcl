packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.1.4"
      source  = "github.com/hashicorp/googlecompute"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "googlecompute" "frontend" {
  project_id   = "project-d465c63d-896c-4a24-818"
  zone         = "us-central1-a"
  
  image_name   = "nginx-frontend-v1"
  image_family = "frontend-images"
  
  source_image_family = "ubuntu-2204-lts"
  ssh_username        = "packer"
  
  service_account_email = "packer@project-d465c63d-896c-4a24-818.iam.gserviceaccount.com"
}

build {
  sources = ["source.googlecompute.frontend"]

  provisioner "shell" {
    inline = ["sudo apt-get update && sudo apt-get install -y python3"]
  }

  provisioner "ansible" {
    playbook_file = "../ansible/site-frontend.yml"
    user          = "packer"
    use_proxy     = false
    roles_path    = "../ansible/roles"
    
    extra_arguments = [
      "--extra-vars", "ansible_sudo_pass=false"
    ]
  }
}