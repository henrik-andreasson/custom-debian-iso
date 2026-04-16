#!/bin/bash

# Default values
VM_NAME="debian-auto-vm"
NETWORK="default"

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -n, --name NAME         VM name (default: debian-auto-vm)
    -h, --help              Display this help message

Example:
    $0 -n my-debian-vm

EOF
    exit 1
}

# Parse command line arguments
OPTS=$(getopt -o n:h --long name:,help -n "$0" -- "$@")

if [ $? != 0 ]; then
    echo "Failed to parse options. Use -h for help." >&2
    exit 1
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
        -n|--name)
            VM_NAME="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done

echo "removing VM  configuration:"
echo "  VM Name: $VM_NAME"
echo ""
virsh dominfo "$VM_NAME"


read -p "enter to remove, ctrl-c to cancel removal" y

virsh destroy "$VM_NAME"
virsh undefine "$VM_NAME"

