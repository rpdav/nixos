# home/\<user\>/common
This is structured very similarly to the hosts folder. All common config goes into the common folder - `common/core` if it's used on all systems or `common/optional` for config that is shared but not used on every system. See the readme in `hosts` for more detail on this layout.

Currently I only have one user, but it's designed to manage users independently. There is sharing of home-manager config across hosts, but not across users. If I make more users in the future, they'll probably be quite minimal and not intended for a real human to use. So they probably won't need much home-manager config, if at all.

# home/\<user\>/<hostname.nix>
This is the home-manager config file referenced in `hosts/common/users`. It contains all host-specific home-manager config and imports any common config used for that user/host combination. Like with hosts, I put as much as possible in `home/<user>/common` to reduce redundant code.
