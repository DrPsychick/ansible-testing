# Ansible testing
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
