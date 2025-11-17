# packer-windows-qemu-ssh

A (relatively) minimal set of scripts and config to build Windows QEMU images with Packer and post-provision them over SSH.

Uses the fact that QEMU natively supports Secure Boot and vTPM rather than any compatibility check bypasses!

Completes all post-provisioning using Ansible over SSH. No dealing with messy/insecure WinRM!

## Goals
* Targets latest Windows Pro N / Windows Server release.
* Installs latest VirtIO drivers into image.
* Aims to enable native platform security features within QEMU.
  * Does not bypass Secure Boot / TPM checks.
* Produces images which are fully updated with Windows Update.
  * Windows runs Windows Update by default after an autounattend.xml it seems.
* SSH enabled for remote management by Ansible.

## Prerequisites
### Install Packer
See: https://developer.hashicorp.com/packer/install

### Install QEMU and Ansible
```sh
sudo dnf install -y qemu swtpm ansible ansible-collection-ansible-windows bsdtar
```

### Download `virtio-win.iso`
```sh
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
```

### Unpack `virtio-win.iso`
This is how we'll provide the VirtIO drivers to our Windows machine. We need to unpack them so Packer can build them into an ISO alongside the `autounattend.xml` file.

```sh
mkdir -p virtio-win && bsdtar -xf virtio-win.iso -C virtio-win && sudo find virtio-win/ -type d -exec chmod u+rwx {} \;
```

## Building

### Enable patched version of Packer QEMU plugin
Needed until the project merges [this pull request](https://github.com/hashicorp/packer-plugin-qemu/pull/226) upstream.

```sh
git clone -b support-qcow2-firmware https://github.com/alexhaydock/packer-plugin-qemu.git
```

```sh
cd packer-plugin-qemu
```

```sh
make dev
```

### Init Packer
```sh
packer init win11_25h2.pkr.hcl
```

### Build Image
```sh
packer build win11_25h2.pkr.hcl
```

## Output

### Login Details
The default username and password for the images is:

```text
admin
```

```text
correct horse battery staple
```

### Image Output
The final `qcow2` image will be outputted into a directory like:
```text
./output-win11_25h2/output-win11_25h2.qcow2
```
