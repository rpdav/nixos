# Current state
## DNS
Nothing in cloudflare
All entries in opnsense
Wireguard/tailscale point to opnsense

## Sources
A phone - wireguard connected back to opnsense
R phone - tailscale
R laptop - tailscale
A laptop - tailscale? check this

# Future state
## DNS
Opnsense for local access - points to local NAS IP

What to use for remote? Can I point to opnsense using unsafe_routes through NAS? If so, probably need to get nas and fw13 talking on local network better, otherwise all requests will go out to lighthouse

Could just put entries in cloudflare pointing to nebula IP. Would need to update both CF and opnsense every time I add a service, though. This is probably simplest.

## Sources
A phone - wireguard
R phone - wireguard? actually, there's a nebula iOS app that could be used.
R laptop - nebula

# Troubleshooting
## hosts can't ping each other on same network
* Turned on relay
    * this works but don't really want to use a relay when on same network
* Opened firewall for all hosts
    * I don't think this made a difference
    * still failed to connect when relay was disabled
* enabled punchy.respond
    * did not work
## handshake errors
* added lighthouse.local_allow_list.interfaces for all hosts. nas was reporting ipv6 to the lighthouse which caused errors when fw13 tried to use that ip
    * seems to have fixed it
