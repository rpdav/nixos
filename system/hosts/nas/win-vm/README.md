# Nixos virtualization recommendations
This document contains notes for myself in case I need to reinstall the VM someday, so it's somewhat bespoke. But here are a few general recommendations from my install experience:
* Helpful resources:
  * Virtualization in general: [Archwiki](https://wiki.archlinux.org/title/Libvirt) and [Nixos wiki](https://wiki.nixos.org/wiki/Libvirt)
  * PCI passthrough and advanced VM tuning: [Archwiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF) and [Nixos](https://wiki.nixos.org/wiki/PCI_passthrough)
* If installing a new VM, start by installing/configuring it imperatively using `virsh` or a tool like `virt-manager`. Once you get it to a state you like, you can copy the xml over to your config.
* If you're doing GPU passthrough using `virt-manager` (and so won't have access to the host's display), you can run `virt-manager` on another machine and connect to the VM host through ssh.
* If installing windows, leave the interface inactive in during install (or use `virtio` networking which won't work without drivers) in order to bypass the account creation requirement.
* If a passed-through GPU doesn't work at install, it might need drivers first. Do the install with `spice` graphics and install the drivers. After that, the `spice` config can be removed.
* Devices intended for passthrough are often bound to the `vfio-pci` kernel driver which makes them unavailable to the host. This is not always required, so try passing through without binding first. If you can get away with not binding to `vfio-pci`, then those devices should be handed back to the host when the VM shuts down.

# Useful commands/scripts
## List PCI devices, IDs, and current IOMMU groups
This script lists the current IOMMU groups. Generally all devices in a group must be passed through at once. If nothing is displayed, that means that IOMMU is not enabled in BIOS.
```
#!/bin/bash
shopt -s nullglob
for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```

## List USB controllers and devices
This command lists USB controllers and connected devices. If IOMMU groups allow, an entire controller can be passed through as a PCI device which will allow USB hot-plugging in the guest. If not, individual USB devices can be passed through using their IDs (formatted like `062a:8503`).
```
for usb_ctrl in /sys/bus/pci/devices/*/usb*; do pci_path=${usb_ctrl%/*}; iommu_group=$(readlink $pci_path/iommu_group); echo "Bus $(cat $usb_ctrl/busnum) --> ${pci_path##*/} (IOMMU group ${iommu_group##*/})"; lsusb -s ${usb_ctrl#*/usb}:; echo; done
```

## Filesystem passthrough
To pass through a linux filesystem like a media share:
1. Enable shared memory in the domain xml
2. Create the `filesystem` block in the domain xml specifying the source on host and the name on the guest
3. Install the `virtiofs` drivers on the guest
4. Install [WinFSP](https://github.com/winfsp/winfsp) on the guest
5. Enable `VirtioFsSvc` and set it to auto-start
