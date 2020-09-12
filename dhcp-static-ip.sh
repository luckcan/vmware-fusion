#!/bin/zsh
VmNet=vmnet8
VmGuest=""
IpAdd=""

FusionDir="/Applications/VMware Fusion.app/Contents/Library"
FusionCfg="/Library/Preferences/VMware Fusion/networking"
DhcpParam="/Library/Preferences/VMware Fusion/$VmNet/dhcpd.conf"
VmDir=~/"Virtual Machines.localized"

# List host networks include NAME, TYPE, DHCP, SUBNET
sudo $FusionDir/vmrun listHostNetworks

# Get vm guest network adapters
VmGuest="mickey"
VmGuestVmx=$VmDir/$VmGuest.vmwarevm/$VmGuest.vmx

sudo $FusionDir/vmrun listNetworkAdapters $VmGuestVmx

# Get guest mac address
VmNet=vmnet1
EthIndex=$(sudo $FusionDir/vmrun listNetworkAdapters $VmGuestVmx | grep $VmNet | awk '{ print $1 }')

MacAdd=$(cat $VmGuestVmx | grep "ethernet${EthIndex}.generatedAddress " | awk '{ print $3 }')

# Clear DHCP reserved IP
sudo $FusionDir/vmnet-cfgcli setdhcpmac2ip ${VmNet} ${MacAdd//\"}

# Set DHCP reserved IP for a guest
IpAdd=192.168.235.11
sudo $FusionDir/vmnet-cfgcli setdhcpmac2ip ${VmNet} ${MacAdd//\"} ${IpAdd}

# Set DHCP lease time by seconds
# default is 1800 seconds
sudo $FusionDir/vmnet-cfgcli setdhcpparam vmnet1 defleasetime 259200
# default is 7200 seconds
sudo $FusionDir/vmnet-cfgcli setdhcpparam vmnet1 maxleasetime 604800

# Generate a new networking file and apply new settings
sudo $FusionDir/vmnet-cli --configure
sudo $FusionDir/vmnet-cli --stop
sudo $FusionDir/vmnet-cli --start

# Check networking config
cat $FusionCfg

# Check dhcpd config
DhcpParam="/Library/Preferences/VMware Fusion/$VmNet/dhcpd.conf"
cat $DhcpParam

# subnet 192.168.235.0 netmask 255.255.255.0 {
#       range 192.168.235.128 192.168.235.254;
#       option broadcast-address 192.168.235.255;
#        option domain-name-servers 192.168.235.1;
#        option domain-name localdomain;
#        default-lease-time 259200;                # default is 30 minutes
#        max-lease-time 604800;                    # default is 2 hours
#        next-server 192.168.235.11;               # For PXE
#        filename "pxelinux\pxelinux.0";           # For PXE
#}
