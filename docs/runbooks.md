# Runbooks

Run Terraform commands from `terraform/` and Ansible commands from `ansible/`.

## Add a machine

1. Add an entry to `vms` in `terraform.tfvars` with a free address.
2. `terraform apply` and read the plan: it should add one VM and change nothing else.
3. `terraform output -raw inventory > ../ansible/inventory.ini`
4. `ansible-playbook site.yml --limit <name>`

## Rebuild a machine from scratch

This destroys the machine's disk. Move anything you need off it first.

```bash
terraform apply -replace='proxmox_virtual_environment_vm.vm["web1"]'
ssh-keygen -R 192.168.10.21          # the rebuilt machine has new host keys
ansible-playbook site.yml --limit web1
```

## Remove a machine

Delete its entry from `vms`, run `terraform apply`, check the plan destroys only that VM, then regenerate the inventory.

## Patch everything now

Security updates install on their own. To apply all pending updates at once and reboot the machines that need it:

```bash
ansible all -b -m ansible.builtin.apt -a "upgrade=dist update_cache=true"
ansible all -b -m ansible.builtin.reboot -a "test_command=uptime" --forks 1
```

`--forks 1` reboots one machine at a time.

## Replace the Proxmox API token

1. In Proxmox, create a new token for the Terraform user (Datacenter → Permissions → API Tokens).
2. Update `PROXMOX_VE_API_TOKEN` wherever you keep it, then run `terraform plan`. It should report no changes.
3. Delete the old token.

## Check for drift

`terraform plan` shows anything changed by hand in Proxmox. `ansible-playbook site.yml --check --diff` shows anything changed by hand on the machines.
