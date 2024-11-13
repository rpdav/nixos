I would prefer to do disk partitioning and installation declaratively using disko, but the nixbook host (an Asus Zenbook) dual boots with Windows and I’m not sure of the best way to do this with disko without wiping the Windows install. Plus, I haven’t figured out a good way to bootstrap secrets during install (particularly for the LUKS passphrase), so for now I just reinstall imperatively.

Some of these are unique to my setup, and are as much a reminder to myself as anything else.

This is adapted from [hadilq’s guide](https://gist.githubusercontent.com/hadilq/f12f5378b74f1bdd440144373dfc5687/raw/5854600045b568107c9cd21b07a0b607329980e3/NixOS-guide.md) and includes:
1. Encrypted swap and root volumes using LUKS and lvm
2. btrfs subvolumes for root, persist, and nix. I don’t have a home partition since I wipe home along with root and just persist what I want to keep with home manager, but an extra subvolume can be easily added

This guide assumes the following disk partitioning: 
1. Partition 1 is the efi system partition
2. Partition 2 through 4 are used by Windows
3. Partition 5 will be used for /boot
4. Partition 6 will include everything else

# Disk partitioning

Create a NixOS live image and boot into it. Connect to wifi if needed and close the install wizard.

Create 2 partitions using your tool of choice. I use 2 GB for boot (p5) and the remaining space for swap and root (p6). If your partition IDs are different, adjust accordingly.
## Format boot and encrypted swap/root partitions
```
sudo -s
DISK=/dev/nvme0n1 # change this to your target disk

mkfs.vfat -n BOOT "$DISK"p5

cryptsetup --verify-passphrase -v luksFormat "$DISK"p6
cryptsetup open "$DISK"p6 crypt

pvcreate /dev/mapper/crypt
vgcreate lvm /dev/mapper/crypt

lvcreate --size 8G --name swap lvm #adjust swap size based on system RAM
lvcreate --extents 100%FREE --name root lvm

mkswap /dev/lvm/swap
mkfs.btrfs /dev/lvm/root

swapon /dev/lvm/swap
```
## Create btrfs subvolumes
```
mount -t btrfs /dev/lvm/root /mnt

btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist

umount /mnt
```
## Mount subvolumes
```
mount -o subvol=root,compress=zstd,noatime /dev/lvm/root /mnt

mkdir /mnt/{nix,persist,boot,efi}
mount -o subvol=nix,compress=zstd,noatime /dev/lvm/root /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/lvm/root /mnt/persist
mount "$DISK"p5 /mnt/boot
mount "$DISK"p1 /mnt/efi
```

# Install
Run
```
nixos-generate-config --root /mnt
```
This will place a `hardware-configuration.nix` and `configuration.nix` file in `/mnt/etc/nixos`.

## hardware-configuration.nix tweaks
Make these tweaks to the generated hardware-configuration.nix file.
* btrfs subvolumes usually are missing the "compress=zstd" and "noatime" options - add those back in.
* `neededForBoot = true;` needs to be added as an option for the /persist volume.

## configuration.nix
Edit the `configuration.nix` file in this directory as needed. At a minimum, the UUID of the encrypted volume (p6 for me) must be updated. Use `lsblk -f` to find UUIDs.

Install:

```
nixos-install
reboot
```

You will be prompted to add a root password during install.

# Restore data
The /persist volume is backed up to my local server using borg. Since borg must authenticate using ssh keys, I’ll need to either:

1. Restore the ssh private key from another location (like a password manager), or
2. Create a temporary ssh key and add its public key to the borg server’s authorized keys file

Since I manage ssh keys declaratively using sops (meaning I don’t have a persisted keyfile), I opt for #2. If you’re running borgserver in a container, you can add the temporary public key directly to `/home/borg/.ssh/authorized_keys` - that way the temporary key will be removed on container restart.

You will also need the encryption passphrase from a password manager.

Mount the backup:
```
mkdir ~/backup
borg mount ssh://borg@serverip/backup/hostname ~/backup
```

Restore the backup to /persist - be mindful of keeping the right permissions for `/etc` and `/home`.

# Bootstrap secrets
There are 2 sops keys - a standalone key in `~/.config` (restored through `/persist/home` backup) for user secrets and a key derived from the host ssh key (restored through `/persist/etc` backup) for system secrets. System rebuild should work fine with keys in `/persist`, but if you need to edit sops.yaml, sops expects those keys to be in ~/.config and /etc/ssh, not persist. If you have to update secrets before enabling impermanence during rebuild, just copy those keys to the default location temporarily.

If you update secrets, don’t forget to update the flake input for the secrets repo.

# Rebuild config
Clone this repo and replace the hardware-configuration.nix file with the auto-generated one in etc/nixos and change file ownership to non-root.

In the main configuration file (`hosts/<hostname>/default.nix`), replace the UUID in the main configuration’s `initrd.luks.devices` block with the UUID of your encrypted partition (p6 for this guide).

Finally run:
```
sudo nixos-rebuild boot --flake .#hostname
```
You can run `nixos-rebuild switch` instead but I find it smoother to activate the config on boot since a lot of services have to be restarted.