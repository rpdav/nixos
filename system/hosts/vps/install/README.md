# Linode VPS Nixos

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

Installation is done as described in the main repo readme.
