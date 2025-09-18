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
R phone - wireguard?
R laptop - nebula
