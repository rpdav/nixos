current state:
a hard-coded backup job "local" is used
backupOpts are used to tweak include/exclude directories and target per host
backupOpts can be independently imported into system for root and into home-manager for users. Those values can be assigned separately (system, user1, and user2 can all have different backupOpts values)

issues:
currently the repo is set based on hostname, which is referenced differently in system (config.networking.hostName) and HM (osConfig.networking...)
also currently implemented as a systemd (non-user) unit which HM can't call

possible fixes:
HM has option `programs.borgmatic` - this could be a good userland backup service. Doesn't seem to accept the same format for includes/excludes, etc.
Could also do a full blown system- and home-manager-compatible module. EmergentMind has something like this, but it's a nixos module, but it's a nixos module.

Migrating from borgbackup to borgmatic:
borgbackup is set up with an excludeList which creates a file read by --exclude-from. Need to translate this to a patterns file that can be used by both programs.

Question: what keys are being used for borg currently and who has access to them?

Put borg pubkeys into nas/services/borg/keys and build the list out declaratively! Don't even need persistent storage in this case. May still need to persist the host keys, though.

# borgmatic setup
backup won't run if repo hasn't been initialized:
borgmatic repo-create --encryption repokey-blake2 (could omit encryption if I figure out how to put that in the HM config - that seems to fail)
repo-create also needs to have the path exist - won't make it first
