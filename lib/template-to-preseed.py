#!/usr/bin/python3
import optparse
import json
# Imports from Jinja2
from jinja2 import Environment, FileSystemLoader

# Load Jinja2 template
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)


parser = optparse.OptionParser(usage="usage: %prog [options]")
parser.add_option("-s", "--server", help="server json file")
parser.add_option("-n", "--network", help="network json file")
parser.add_option("-o", "--support", help="support json file")
parser.add_option("-p", "--packages", help="packages json file")
parser.add_option("-t", "--template", help="debian preseed jinga2 template file")

opts, args = parser.parse_args()

serverinfo = {}
jingadata = {}
if opts.server:

    with open(opts.server, 'r') as f:
        serverinfo = json.load(f)
    short_hostname = serverinfo['hostname'].split('.', 1)[0]
    domainname = serverinfo['hostname'].split('.', 1)[1]
    jingadata = {'short_hostname': short_hostname, 'domainname': domainname}

if opts.template:
    template = env.get_template(opts.template)
else:
    template = env.get_template('lib/preseed.template')


netinfo = {}
if opts.network:
    with open(opts.network, 'r') as f:
        netinfo = json.load(f)

packagesinfo = {}
if opts.packages:
    with open(opts.packages, 'r') as f:
        packagesinfo = json.load(f)

packagesinfo = {}
if opts.support:
    with open(opts.support, 'r') as f:
        support = json.load(f)

for key, value in serverinfo.items():
    newkey = f'server_{key}'
    jingadata[newkey] = value

for key, value in netinfo.items():
    newkey = f'net_{key}'
    jingadata[newkey] = value

for key, value in packagesinfo.items():
    jingadata[key] = value

for key, value in support.items():
    newkey = f'support_{key}'
    jingadata[newkey] = value

print(template.render(jingadata))
