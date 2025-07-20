current state:
a hard-coded backup job "local" is used
backupOpts are used to tweak include/exclude directories and target per host
backupOpts can be independently imported into system for root and into home-manager for users. Those values can be assigned separately (system, user1, and user2 can all have different backupOpts values)

issues:
currently the repo is set based on hostname, which is referenced differently in system (config.networking.hostName) and HM (osConfig.networking...)
also currently implemented as a systemd (non-user) unit which HM can't call

Put borg pubkeys into nas/services/borg/keys and build the list out declaratively! Don't even need persistent storage in this case. May still need to persist the host keys, though.

# Todo
- [ ] reconfigure system backup to be root-specific
- [ ] put in real directory excludes and remove AC power exception
- [ ] test out on vps and nas?
- [ ] clean up code - some backupOpts may not be needed. Are the right things being declared in the right places?
- [ ] start on remote backup
