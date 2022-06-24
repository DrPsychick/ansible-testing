# Ansible testing
[![Build Status](https://travis-ci.com/DrPsychick/ansible-testing.svg?branch=master)](https://app.travis-ci.com/github/DrPsychick/ansible-testing)
[![license](https://img.shields.io/github/license/drpsychick/ansible-testing.svg)](https://github.com/drpsychick/ansible-testing/blob/master/LICENSE)
[![Paypal](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=FTXDN7LCDWUEA&source=url)
[![GitHub Sponsor](https://img.shields.io/badge/github-sponsor-blue?logo=github)](https://github.com/sponsors/DrPsychick)

Creates instances which you can use to test your Ansible roles with.

## Configuration
Check [defaults/main.yml](defaults/main.yml) see how to define instances and adjust it to your needs.

## Contribution
If you have more systems you want to test, feel free to provide a PR with an additional Dockerfile.

# Usage
Requirements: Linux (as it spawns containers in `privileged` mode and binds `/sys/fs/cgroup`)

## Standalone
```shell
# edit tests/provision.yml to your needs
echo "[defaults]
roles_path = .." > ansible.cfg

# create instances
ansible-playbook tests/create.yml

# destroy instances
ansible-playbook tests/destroy.yml
```

## With `molecule`
TODO
