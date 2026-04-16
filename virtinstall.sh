#!/bin/bash

# Default values
VM_NAME="debian-auto-vm"
DISK_SIZE="80" # in GB
RAM_MB="4096"
VCPUS="2"
ISO_PATH=""
PRESEED_FILE=""
NETWORK="default"

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -i, --iso PATH          Path to the Debian ISO file (required)
    -p, --preseed FILE      Preseed filename (required)
    -n, --name NAME         VM name (default: debian-auto-vm)
    -N, --network NETWORK   Network configuration (default: default)
    -h, --help              Display this help message

Example:
    $0 -i /path/to/debian.iso -p preseed.cfg -n my-debian-vm
    $0 --iso debian.iso --preseed preseed.cfg --name test-vm --network bridge=br0

EOF
    exit 1
}

# Parse command line arguments
OPTS=$(getopt -o i:p:n:N:h --long iso:,preseed:,name:,network:,help -n "$0" -- "$@")

if [ $? != 0 ]; then
    echo "Failed to parse options. Use -h for help." >&2
    exit 1
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
        -i|--iso)
            ISO_PATH="$2"
            shift 2
            ;;
        -p|--preseed)
            PRESEED_FILE="$2"
            shift 2
            ;;
        -n|--name)
            VM_NAME="$2"
            shift 2
            ;;
        -N|--network)
            NETWORK="$2"
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

# Validate required arguments
if [ -z "$ISO_PATH" ]; then
    echo "Error: ISO path is required (-i or --iso)" >&2
    usage
fi

if [ -z "$PRESEED_FILE" ]; then
    echo "Error: Preseed file is required (-p or --preseed)" >&2
    usage
fi

# Check if ISO file exists
if [ ! -f "$ISO_PATH" ]; then
    echo "Error: ISO file not found: $ISO_PATH" >&2
    exit 1
fi

PRESEED_FILE_PATH="/cdrom/isolinux/$PRESEED_FILE"

echo "Starting VM installation with the following configuration:"
echo "  VM Name: $VM_NAME"
echo "  ISO Path: $ISO_PATH"
echo "  Preseed File: $PRESEED_FILE_PATH"
echo "  Disk Size: ${DISK_SIZE}GB"
echo "  RAM: ${RAM_MB}MB"
echo "  vCPUs: $VCPUS"
echo "  Network: $NETWORK"
echo ""

virt-install \
  --name "$VM_NAME" \
  --ram "$RAM_MB" \
  --vcpus "$VCPUS" \
  --disk path=/var/lib/libvirt/images/"$VM_NAME".qcow2,size="$DISK_SIZE",format=qcow2 \
  --os-variant debiantesting \
  --network "$NETWORK" \
  --location "$ISO_PATH" \
  --extra-args "auto=true priority=critical preseed/file=$PRESEED_FILE_PATH"

#console=ttyS0,115200n8
#  --graphics none \
#  --console pty,target_type=serial \
