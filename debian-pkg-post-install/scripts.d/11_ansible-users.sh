#!/bin/bash

echo "localhost" > /etc/ansible/hosts.localhost
/usr/bin/ansible-playbook -vv -i /etc/ansible/hosts.localhost --connection=local --limit=localhost /etc/ansible/playbook-users
