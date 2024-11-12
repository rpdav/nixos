I would prefer to do disk partitioning and installation declaratively using disko, but the nixbook host (an Asus Zenbook) dual boots with Windows and I’m not sure of the best way to do this with disko without wiping the Windows install. Plus, I haven’t figured out a good way to bootstrap secrets during install (particularly for the LUKS passphrase), so for now I just install imperatively.

This is adapted from [hadilq’s guide](https://gist.githubusercontent.com/hadilq/f12f5378b74f1bdd440144373dfc5687/raw/5854600045b568107c9cd21b07a0b607329980e3/NixOS-guide.md) and includes:
1. Encrypted swap and root volumes using LUKS and lvm
2. btrfs subvolumes for root, persist, and nix. I don’t have a home partition since I wipe home along with root and just persist what I want to keep with home manager, but an extra subvolume can be easily added

This guide assumes the following disk partitioning: 
1. Partition 1 is the efi system partition
2. Partition 2 through 4 are used by Windows
3. Partition 5 will be used for /boot
4. Partition 6 will include everything else

# Disk Partitioning

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
## Mount subvolumes and generate config
```
mount -o subvol=root,compress=zstd,noatime /dev/lvm/root /mnt

mkdir /mnt/{nix,persist,boot,efi}
mount -o subvol=nix,compress=zstd,noatime /dev/lvm/root /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/lvm/root /mnt/persist
mount "$DISK"p5 /mnt/boot
mount "$DISK"p1 /mnt/efi

nixos-generate-config --root /mnt

```

## hardware-configuration.nix tweaks
Make these tweaks to the generated hardware-configuration.nix file.
* btrfs subvolumes usually are missing the "compress=zstd" and "noatime" options - add those back in.
* `neededForBoot = true;` needs to be added as an option for the /persist volume.

## configuration.nix tweaks
Add these lines to the generated configuration.nix file. use `lsblk -f` to find uuids

```
## Enable flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

## Enable support for encrypted partition
## Remove any other auto-generated boot.loader lines
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
    };
    initrd.luks.devices = {
      crypt = {
                 ## UUID of the encrypted partition 
        device = "/dev/disk/by-uuid/xxxxx";
        preLVM = true;
      };
    };
  };

## Useful packages for intial reinstall
  environment.systemPackages = with pkgs; [
    firefox
    git
    vim
    borgbackup
    tree
    sops
    ssh-to-age
  ];

## Define primary user
  users.users.yourname = {
    hashedPassword = "Run mkpasswd -m sha-512 to generate";
    isNormalUser = true; 
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

```
You can also make any extra tweaks you’d like to be in place before doing the final config restore (like setting timezone)

Finally you can run:

```
nixos-install
reboot
```

You will be prompted to add a root password during install.

# Restore /persist from backup
The /persist volume is backed up to my local server using borg. Since borg must authenticate using ssh keys, we’ll need to either:

1. Restore the ssh private key from another location (like a password manager), or
2. Create a temporary ssh key and add its public key to the borg server’s authorized keys file

Since I manage ssh keys declaratively using sops (meaning I don’t have a persisted keyfile), I opt for #2. If you’re running borgserver in a container, you can add the temporary public key directly to `/home/borg/.ssh/authorized_keys` - that way the temporary key will be removed on container restart.

You will also need the encryption passphrase from a password manager.

Mount the backup:
```
mkdir ~/backup
borg mount ssh://borg@serverip/backup/hostname ~/backup
```

Restore the backup to /persist - be mindful of keeping the right permissions for /etc and /home

# Bootstrap secrets
There are 2 sops keys - a standalone key in ~/.config (restored through /persist/home backup) for user secrets and a key derived from the host ssh key (restored through /persist/etc backup) for system secrets. System rebuild should work fine with keys in /persist, but if you need to edit sops.yaml, sops expects those keys to be in ~/.config and /etc/ssh, not persist. If you have to update secrets before enabling impermanence, just copy those keys to the default location temporarily.

If you update secrets, don’t forget to update the flake input for the secrets repo.

# Rebuild config
clone the nixos repo and cd into it
rm
Replace the hardware-configuration.nix file with the auto-generated one in etc/nixos and change file ownership to non-root.

Replace the UUID in the main configuration’s initrd.luks.devices block with the UUID of your encrypted partition (nvme0n1p6 for this guide).

NOTE initial rebuild requires root ssh key added to git. makes sense to use the same root temp ssh key to pull down persist backup and initial rebuild.

`sudo nixos-rebuild boot --flake .#hostname`
