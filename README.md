# Ansible testing
[![Build Status](https://travis-ci.com/DrPsychick/ansible-testing.svg?branch=master)](https://app.travis-ci.com/github/DrPsychick/ansible-testing)
[![license](https://img.shields.io/github/license/drpsychick/ansible-testing.svg)](https://github.com/drpsychick/ansible-testing/blob/master/LICENSE)
[![Paypal](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=FTXDN7LCDWUEA&source=url)
[![GitHub Sponsor](https://img.shields.io/badge/github-sponsor-blue?logo=github)](https://github.com/sponsors/DrPsychick)

Creates fully functional SystemD instances which you can use to test your Ansible roles with.
Intended to be run locally on a Linux box with Docker installed.

## Configuration
Check [defaults/main.yml](defaults/main.yml) see how to define instances and adjust it to your needs.
* Define your own `work_dir`. The contents are temporary and will be removed with `destroy`!
* Define the instances you want to spin up.

## Contribution
If you have more systems you want to test, feel free to provide a PR with an additional Dockerfile.

# Usage
Requirements: 
* Linux (as it spawns containers in `privileged` mode and binds `/sys/fs/cgroup`)
* Docker (maybe supporting libvirt/kvm in the future)

## Standalone
Write your own playbook or use the playbooks in `tests`
```shell
# edit tests/provision.yml to your needs
echo "[defaults]
roles_path = .." > ansible.cfg

# create instances
ansible-playbook tests/create.yml

# destroy instances
ansible-playbook tests/destroy.yml
```

## With Ansible `molecule`
Create your role, then copy the `docs/molecule` directory into your roles directory. 

Requirements
* `pip3 install -U molecule molecule-docker`

Adjust the `molecule/default/vars.yml` to define which instances to provision.
Then adjust the `platforms` in `molecule.yml` accordingly.

`vars.yml`
```yaml
work_dir: "/tmp/ansible-testhost"
containers:
  - { name: fedora36, os: fedora, dockerfile: Dockerfile_Fedora, files: ["entrypoint.sh"], args: { VERSION: 36 } }
  - { name: ubuntu2204, os: ubuntu, dockerfile: Dockerfile_Ubuntu, files: ["entrypoint.sh"], args: { VERSION: 22.04 } }
  - { name: centos8, os: centos, dockerfile: Dockerfile_CentOS, files: ["entrypoint.sh"], args: { VERSION: 8 } }
```

`molecule.yml`
```yaml
[...]
platforms:
  - name: fedora36
  - name: ubuntu2204
  - name: centos8
[...]
```

Finally, include your role in `converge.yml`
```yaml
---
- name: Converge
  hosts: all
  tasks:
    - name: "Include myrole"
      ansible.builtin.include_role:
        name: "myrole"
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
