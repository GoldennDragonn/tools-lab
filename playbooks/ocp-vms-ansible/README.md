
Run the playbook for each set of VMs:

`ansible-playbook -i inventory.ini create_vms.yml --limit masters`
`ansible-playbook -i inventory.ini create_vms.yml --limit workers`
`ansible-playbook -i inventory.ini create_vms.yml --limit infras`