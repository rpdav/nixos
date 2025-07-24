initial borg run fails because systemd can't accept the new host key; has to be done imperatively.

should borg host keys be added to secrets/config so that they can be added to each system on build? other keys would need to be added to the regular known hosts file, but this would make that first run smoother.
