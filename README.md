# Ansible testing
[![Build Status](https://img.shields.io/github/actions/workflow/status/DrPsychick/ansible-testing/ci.yml
)](https://github.com/DrPsychick/ansible-testing/actions/workflows/ci.yml)
[![license](https://img.shields.io/github/license/drpsychick/ansible-testing.svg)](https://github.com/drpsychick/ansible-testing/blob/main/LICENSE)
[![Paypal](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=FTXDN7LCDWUEA&source=url)
[![GitHub Sponsor](https://img.shields.io/badge/github-sponsor-blue?logo=github)](https://github.com/sponsors/DrPsychick)

Creates fully functional SystemD docker containers which you can use to test your Ansible roles with. 
With `libvirt` you can also automatically provision Windows virtual machines to test your roles with `WinRM`.
Intended to be run locally on a Linux box with Docker (and optionally libvirt) installed.

## Configuration
Check [defaults/main.yml](defaults/main.yml) see how to define containers and adjust it to your needs.
* Define your own `work_dir`. The contents are temporary and will be removed with `destroy`!
* Define the containers you want to spin up.

## What it does (in a nutshell)
This role has `create` and `destroy` tasks for containers and virtual machines. It loops over the configured lists 
(`containers` or `virtual_machines` in `vars.yml`) and creates the instances accordingly. 
Each Molecule scenario must either use containers **or** virtual machines, because Molecule only supports a single driver per scenario.

Linux: It creates privileged docker containers that are started with `/sbin/init` to have a fully SystemD capable instance.

Windows: It creates the VM (unattended install of Windows) and configures WinRM for Ansible (plain HTTP) upon first start.

**Hint:** Creating Windows VMs is expensive and takes over 10 Minutes.

# Contributing
If you have other systems you want to test, feel free to provide a PR with additional Dockerfiles or libvirt configuration.

Contributing is really easy:
1. Fork the project on GitHub : https://github.com/DrPsychick/ansible-testing
1. Checkout the fork on your Linux box
1. Symlink the fork in your roles Molecule scenario (i.e. `./molecule/default/`)
1. Make changes and test your role with them until you're happy - commit and create a pull-request
1. You can run GitHub Actions locally for fast feedback with `act`: https://nektosact.com/installation/index.html

```shell
GitHubName=YourName
YourRoleDir=/This/Is/Your/Role/Directory/MyRole
YourRoleName=MyRole
WhereYourForkIs=/This/Is/Where/You/Clone/Your/Fork

# clone your fork
cd $WhereYourForkIs
git clone https://github.com/$GitHubName/ansible-testing.git

# symlink your local version in your molecule scenario
cd $YourRoleDir/molecule/default
ln -s $WhereYourForkIs/ansible-testing drpsychick.ansible_testing

# comment out role in requirements and delete downloaded version
sed -i -e 's/^ /# /' requirements.yml
rm -rf ~/.cache/molecule/$YourRoleName/default/roles/drpsychick.ansible_testing
```

Now, when you run `molecule` it will use the symlink to include the `drpsychick.ansible_testing` role.
Make your changes, commit regularly and when you're done, don't forget to create a pull-request so others can benefit 
from your improvements as well. What's more is that you can test the role itself with Molecule: 
just execute `molecule test` in your local fork directory.

# Usage
Requirements: 
* Linux (as it spawns containers in `privileged` mode and binds `/sys/fs/cgroup`)
* Docker
* libvirt (for Windows virtual machines)

# Test with Docker containers (Linux)
Requirements
* `pip3 install -U molecule molecule-docker`

## With Ansible `molecule`
Create a new role with `molecule init role <name>` or initialize the Molecule scenario in an existing role directory with
`molecule init scenario default`.

Download the example files from this repo which make use of this role (in `create` and `destroy`):
```shell
for f in create destroy molecule requirements vars; do
  curl -o molecule/default/$f.yml https://raw.githubusercontent.com/DrPsychick/ansible-testing/main/docs/molecule/default/$f.yml
done
```

Adjust the `molecule/default/vars.yml` to define which containers to provision.
Then adjust the `platforms` in `molecule/default/molecule.yml` accordingly.

`vars.yml`
```yaml
work_dir: "/tmp/ansible-testrole-default"
containers:
  - { name: fedora40, os: fedora, dockerfile: Dockerfile_Fedora, files: ["entrypoint.sh"], args: { VERSION: 40 } }
  - { name: ubuntu2404, os: ubuntu, dockerfile: Dockerfile_Ubuntu, files: ["entrypoint.sh"], args: { VERSION: 24.04 } }
  - { name: centos7, os: centos, dockerfile: Dockerfile_CentOS, files: ["entrypoint.sh"], args: { VERSION: 7 } }
```

`molecule.yml`
```yaml
[...]
platforms:
  - name: fedora40
  - name: ubuntu2404
  - name: centos7
[...]
```

Run molecule
```shell
# steps separately
molecule dependency
molecule create
molecule prepare
molecule converge
molecule idempotence
molecule verify
molecule cleanup
molecule destroy

# or everything in one go
molecule test
```

## Standalone
Write your own playbook or use the playbooks in `tests`
```shell
ansible-galaxy install -r requirements.yml

# edit tests/provision.yml to your needs
echo "[defaults]
roles_path = .." > ansible.cfg

# create containers
ansible-playbook tests/create.yml

# destroy containers
ansible-playbook tests/destroy.yml
```


# Test with Windows VMs
Requirements
* install `libvirt`, `libvirt-clients`, `virtinst`
* ansible-galaxy `community.libvirt`
* for Ansible to connect with WinRM: `python3-winrm`
* see [defaults/main.yml](defaults/main.yml)
  * Download the Windows Image of your choice (Test is setup for Windows 2016)
  * Download the VirtIO ISO
  * Put both ISOs into the `libvirt_iso_dir`

```shell
# download the ISOs
sudo curl -Lo /var/lib/libvirt/isos/WindowsServer2016.iso http://care.dlservice.microsoft.com/dl/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO
sudo curl -Lo /var/lib/libvirt/isos/virtio-win.iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
```

## Use libvirt as user (no become/sudo)
Create `image` and `iso` pool that is writeable by the user and set the permissions of the pool accordingly.
Make sure the user is part of 
```shell
sudo virsh pool-create-as myisos dir --target /mydir/libvirt/isos
sudo virsh pool-edit isos # set permissions

sudo virsh pool-create-as myimages dir --target /mydir/libvirt/images
sudo virsh pool-edit images2 # set permissions
```

Reference the directories and pool in your `molecule/libvirt/vars.yml`
```shell
libvirt_image_dir: "/mydir/libvirt/images"
libvirt_iso_dir: "/mydir/libvirt/isos"
libvirt_disk_pool: "myimages"
```


## With Ansible `molecule`
Create a new role with `molecule init role <name>` or initialize the Molecule scenario in an existing role directory with
`molecule init scenario default`.

Download the example files from this repo which make use of this role (in `create` and `destroy`):
```shell
for f in create destroy molecule requirements vars; do
  curl -o molecule/libvirt/$f.yml https://raw.githubusercontent.com/DrPsychick/ansible-testing/main/docs/molecule/libvirt/$f.yml
done
```

Adjust the `molecule/libvirt/vars.yml` to define which containers to provision.
Then adjust the `platforms` in `molecule/libvirt/molecule.yml` accordingly.

```shell
# run the scenario "libvirt"
molecule test -s libvirt
```

## Standalone
```shell
ansible-galaxy install -r requirements.yml

# edit tests/provision.yml to your needs
echo "[defaults]
roles_path = .." > ansible.cfg

# create virtual machine
ansible-playbook tests/create_vm.yml

# destroy virtual machine
ansible-playbook tests/destroy_vm.yml
```

## Using predefined Windows images to speed up provisioning
A full spin-up (create) run for 2 Windows instances with predefined images took **less than 4 minutes** on my i7.
1. Create a `qcow2` image or simply provision a VM once with unattended install
2. Create a zip from the ready to use VM: `zip windows2016-clean.qcow2.zip windows2016.qcow2`
   (the filename must match and be in the root of the zip file - with no path)
3. Move the zip file to `libvirt_iso_dir` or provide it via URL (`disk_image_url`)

# Test locally with different Ansible versions

Requires `python3-venv`

```shell
# version 16 and latest fail with
# ERROR! Unexpected Exception, this is probably a bug: cannot import name 'should_retry_error' from 'ansible.galaxy.api'
ANSIBLE_VERSION=15
python3 -m venv .venv
. .venv/bin/activate
pip3 install --upgrade pip setuptools wheel
pip3 install --requirement requirements-ansible_${ANSIBLE_VERSION}.txt

molecule test
```
