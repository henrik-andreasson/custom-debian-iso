#!/bin/bash

echo "localhost" > /etc/ansible/hosts.localhost

cat << EOF  > /etc/ansible/playbook-users
- hosts: all
  gather_facts: no
  tasks:

  - group: name=andreassonhe gid=2001 state=present
  - user:  name=andreassonhe uid=2001 comment="Henrik Andreasson" group=andreassonhe
  - authorized_key: user=andreassonhe key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDW0bTIwdUu1JdLEpSYLczjXstXVsPpT2mua3RqAYXX8GTPqhFjBMAtjaWLC2Q9G1Pbpf0AlTCKCAGvynaVHa5GGxSxbMd2wNWFYMdP1pqXuNrXaQ8A0SxIl+6VFs8sVXk8rioxzIP4h+KoDAbRefR80JeBXIw1gCRuHjUR/+ThAF8Ug7rOQkSpLpQdcJMcmpH4pATON3tMQDWX9qdcknwEB6Mb+ZHIwvEnyCXhUqJjsr54wcBSpj3Ne9UjXJN1gzRwzSCQKO1W3DIAXwuUutdFAzjvCMN1iyEygobcq6VGjXRhl+ag1O6AqFkNMc+RGwM7lUhdE1Kld7JXNL7msYtB han@boing"

EOF
/usr/bin/ansible-playbook -vv -i /etc/ansible/hosts.localhost --connection=local --limit=localhost /etc/ansible/playbook-users
