# Linode VPS Nixos

## nixos-anywhere notes

`nixos-anywhere` authenticates over ssh several times in the install process, so if keys are used it will prompt for the passphrase or yubikey touch several times. I recommend sticking with password ssh for the install because it doesn't really take long.

`nixos-anywhere` expects to be run in the same directory as `flake.nix`. It won't seach upward like `nixos-rebuild`

`nixos-anywhere` can either install onto a machine booted into a nixos installer or onto a separate booted linux distro by using kexec. The docs say that a minimum of 1 GB RAM is needed for kexec, but I had better luck with 2 GB.

## VPS prep

This is adapted from the [Linode NixOS guide](https://www.linode.com/docs/guides/install-nixos-on-linode/).

This guide requires a separate ~1 GB disk be used for the installer image. The main disk image will need to be shrunk by that amount or the VPS temporarily upsized to create an extra disk. I run this VPS with only 1 GB RAM, so I need to upsize to 2 GB to support kexec anyway, so I just temporarily create the installer disk and delete it later.

### Create Disks

[Create two disk images](/docs/products/compute/compute-instances/guides/disks-and-storage/#create-a-disk): One for the installer and one for the root partition. Label them:

- **Installer**: A type `ext4` disk, 1280 MB in size.
- **NixOS**: A raw disk which will be overwritten by `nixos-anywhere`. If you plan to downgrade to a 1 GB instance after install, use a size of 25,600 MB for this disk.

### Create Configuration Profiles

[Create two configuration profiles](/docs/products/compute/compute-instances/guides/configuration-profiles/#create-a-configuration-profile), one for the installer and one to boot NixOS. For each profile, disable all of the options under **Filesystem/Boot Helpers** and set the **Configuration Profile** to match the following:

-   **Installer profile**

    - **Label:** Installer
    - **Kernel:** Direct Disk
    - **/dev/sda:** *NixOS*
    - **/dev/sdb:** *Installer*
    - **root / boot device:** Standard: /dev/sdb

-   **Boot profile**

    - **Label:** NixOS
    - **Kernel:** Direct Disk
    - **/dev/sda:** *NixOS*
    - **root / boot device:** Standard: /dev/sda

### Prepare the Installer

1.  In your browser, navigate to the [NixOS download page](https://nixos.org/nixos/download.html) and copy the URL from the **Minimal installation CD, 64-bit Intel/AMD** link.

1.  [Boot your Linode into rescue mode](/docs/products/compute/compute-instances/guides/rescue-and-rebuild/#boot-into-rescue-mode) with the **Installer** disk mounted as `/dev/sda`.

1.  Once in rescue mode, click the **Launch Console** link to launch the Finnix rescue console and run the following commands, replacing the URL with the latest 64-bit minimal installation image copied from the [NixOS download page](https://nixos.org/nixos/download.html):

	```command
    # Update SSL certificates to allow HTTPS connections:
    update-ca-certificates

    # set the iso url to a variable
    iso=<URL for nixos download>

    # Download the ISO, write it to the installer disk, and verify the checksum:
    curl -L $iso | tee >(dd of=/dev/sda) | sha256sum
    ```

1.  The checksum should be the same as that in the contents of the checksum file linked next to the download link. Verify it before proceeding.

### Boot the Installer

1. In your Linode's dashboard, boot into your **Installer** configuration profile. Since the installer image isn't configured to support SSH or the LISH console, connect to your Linode using [GLISH](/docs/products/compute/compute-instances/guides/glish/).

1. Set a root password to enable ssh with `nixos-anywhere`:

	```command
	# switch to root
	sudo -i
	# set a password
	passwd

	```

1. Close the GLISH console - install will be done over ssh.

## Install

1. Copy any files that need to be on the new host to `~/anywhere` (this can of course be changed). This directory should mimic the root of the target host (e.g. `~/anywhere/persist`, `~/anywhere/etc`). At a minimum this should include the user age key in `~/.config/sops/keys.txt` and host ssh key in `/etc/ssh`. If the system is impermanent, use the file locations within the persistent directory. Docker persistent data should be copied as well to prevent the containers from creating boilerplate data that will have to be replaced later.

1. Install with `nixos-anywhere` in the same directory as `flake.nix`:

	```command
	nix run github:nix-community/nixos-anywhere -- --flake .#vps --extra-files ~/anywhere --generate-hardware-config nixos-generate-config ./system/hosts/vps/hardware-configuration.nix root@vps
	```

1. Once install completes, boot into the NixOS configuration profile in the Linode console.

1. Once rebooted, ssh in and verify everything looks good.

1. Delete the Installer volume and downgrade to a nanode if desired.

## Remote rebuilding
Rebuild remotely using `nixos-rebuild --flake .vps --target-host root@vps switch`. `sudo` isn't necessary since you're connecting as root. If you use `sudo` it will try to use root's ssh keys.
