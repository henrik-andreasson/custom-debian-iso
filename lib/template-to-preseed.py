#!/usr/bin/python3
import optparse
import json
# Imports from Jinja2
from jinja2 import Environment, FileSystemLoader

parser = optparse.OptionParser(usage="usage: %prog [options]")
parser.add_option("-s", "--server", help="server json file")
parser.add_option("-n", "--network", help="network json file")
parser.add_option("-p", "--packages", help="packages json file")
parser.add_option("-t", "--template", help="preseed template")

opts, args = parser.parse_args()

if opts.template:
    template_file = opts.template
else:
    template_file = 'lib/preseed.template'

# Load Jinja2 template
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template(template_file)


serverinfo = {}
jingadata = {}
if opts.server:

    with open(opts.server, 'r') as f:
        serverinfo = json.load(f)
    short_hostname = serverinfo['hostname'].split('.', 1)[0]
    domainname = serverinfo['hostname'].split('.', 1)[1]
    jingadata = {'short_hostname': short_hostname, 'domainname': domainname}

netinfo = {}
if opts.network:
    with open(opts.network, 'r') as f:
        netinfo = json.load(f)

packagesinfo = {}
if opts.packages:
    with open(opts.packages, 'r') as f:
        packagesinfo = json.load(f)

for key, value in serverinfo.items():
    newkey = f'server_{key}'
    jingadata[newkey] = value

for key, value in netinfo.items():
    newkey = f'net_{key}'
    jingadata[newkey] = value

for key, value in packagesinfo.items():
    jingadata[key] = value

# Render template using data and print the output
print(template.render(jingadata))
