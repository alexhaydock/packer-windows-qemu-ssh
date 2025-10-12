packer {
  required_plugins {
    qemu = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/qemu"
    }

    ansible = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

# Set to `false` for easier build debugging
variable "headless" {
  type    = string
  default = "true"
}

# Get the checksum from this page:
# https://www.microsoft.com/en-gb/software-download/windows11
variable "iso_checksum" {
  type    = string
  default = "sha256:BAAEB6C90DD51648154B64C40C9E0C14D93A427F611A1BB49C8077FA2FF73364"
}

# Get the link from this page:
# https://git.activated.win/massgrave/massgrave.dev/src/branch/main/docs/windows_11_links.md
variable "iso_url" {
  type    = string
  default = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENT_CONSUMER_x64FRE_en-gb.iso"
}

variable "vm_name" {
  type    = string
  default = "win11_25h2"
}

source "qemu" "win11_25h2" {
  accelerator = "kvm"
  # Handle the "Press any key..." prompt we get
  boot_command              = ["x"]
  boot_wait                 = "-1s"
  cd_files                  = ["./autounattend/11/autounattend.xml", "./virtio-win/"]
  communicator              = "ssh"
  cpu_model                 = "host"
  cpus                      = "4"
  disk_compression          = "true"
  disk_interface            = "virtio"
  disk_size                 = "64G"
  efi_drop_efivars          = "true"
  efi_firmware_code         = "OVMF_CODE_4M.secboot.fd"
  efi_firmware_vars         = "OVMF_VARS_4M.secboot.fd"
  format                    = "qcow2"
  headless                  = "${var.headless}"
  iso_checksum              = "${var.iso_checksum}"
  iso_url                   = "${var.iso_url}"
  machine_type              = "q35"
  memory                    = "8192"
  net_device                = "virtio-net"
  ssh_clear_authorized_keys = "true"
  ssh_password              = "password123"
  ssh_timeout               = "1h"
  ssh_username              = "admin"
  vga                       = "qxl"
  vtpm                      = "true"
}

build {
  sources = ["source.qemu.win11_25h2"]

  # This provisioner waits cleanly for SSH to be available
  # unlike the Ansible one
  provisioner "powershell" {
    inline = ["Write-Host 'hello world'"]
  }

  # Run Ansible to post-provision host
  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yml"
  }
}
