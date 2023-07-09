#!/bin/bash

echo "localhost" > /etc/ansible/hosts

ansible-playbook --connection=local /etc/ansible/playbook-users -vv  --limit=localhost
