# GPU passthrough
Need to use spice graphics until GPU drivers can be installed, then it can be removed.

# USB passthrough
Most usb ports (rear 3.0, rear 2.0, and front 3.0) are on controller 03:00.0. This is in an iommu group with other devices (PCI ports, including host boot drive, sata controllers). This would need acs override and might conflict with boot drive.

2 rear 3.0 ports are on controller 28:00.3 which is its own iommu group. Wouldn't need acs override and could just use existing hubs. Only 2 ports though - need to route USB audio up to a hub or try passing host audio through.

## VM devices
* 3.0 hub
  * bluetooth?
  * flash drives as needed
  * A to C adapter
  * usb audio? could chain hubs if audio passthrough doesn't work. Also don't really want this swapping to the laptop dock, so avoid 2.0 hub
* 2.0 hub (hot swap to dock)
  * keyboard
  * keyboard charge cable
  * mouse

## Host devices
* 3.0 
  * power supply? (e.g. bluetooth audio streamer)
* 2.0 
  * zwave
  * UPS
* front
  * leave open for kb/mouse and flash drives

# helpful scripts #TODO
list PCI devices and IDs
list IOMMU groups
list which USB devices are connected to which controllers

# Install notes
Devices needing drivers: GPU, mobo audio 
Use virtio network adapter but don't install drivers until after OS install in order to bypass account creation

# Wrapup tasks
* CPU tuning
* Reinstall on NVME with correct uuid
* Install virtio drivers
* Try passing through GPU without stubbing or blacklisting
* Get windows reactivated
* Reinstall games
* Upgrade to win11? May need tpm support
* Re-manage cables
