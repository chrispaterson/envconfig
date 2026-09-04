---
name: vpn-lan-access
description: "How to reach home LAN machines (M1 Ultra gbrain host, iMac, Home Assistant, Ubiquiti) while Adobe GlobalProtect VPN is connected"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 2c0e029b-c584-46e6-8638-cba82ec33d50
  modified: 2026-08-18T02:02:46.821Z
---

Adobe GlobalProtect (full tunnel, portal vpn.adobe.com) captures all LAN IPv4: it routes 192.168.1.0/24 into utun4 and PanGPS actively re-stomps any IPv4 host-route workaround. **Do not fight the v4 routing table.**

GlobalProtect ignores IPv6 entirely, and mDNS (link-local multicast) still works on VPN. Standard name resolution returns IPv6 link-local addresses with the en0 scope, so **using `.local` hostnames just works even with the VPN up**:

- Mac Studio (gbrain host): `m1-ultra.local` = 192.168.1.172 wired (DHCP-reserved) / 192.168.1.114 Wi-Fi; link-local `fe80::429:e8aa:c722:544a%en0`. SSH verified on VPN.
- Home Assistant: `homeassistant.local` = 192.168.1.25; ports 8123 and 22 verified on VPN (see [[reference_homeassistant_ssh_access]]).
- iMac: `imac.local` (mDNS instance "Chris's iMac"); SSH verified on VPN.
- Ubiquiti router: 192.168.1.1, link-local `fe80::6c63:f8ff:fe59:69f8%en0`; :443 listens on v6 but browsers reject zone-id URLs — the UI is permanently tunneled to https://localhost:8443 by the LaunchAgent `~/Library/LaunchAgents/com.paterson.router-tunnel.plist` (ssh -L via m1-ultra.local, KeepAlive/NetworkState, errors to /tmp/router-tunnel.err). UniFi cloud console is the fallback.

Anything that needs raw IPv4 or does non-getaddrinfo resolution: tunnel through the Studio as SSH jump host/beachhead (it has unrestricted LAN access).

The LAN also has a ULA prefix fde2:663d:9982:42dd::/64 (likely announced by an Apple Thread border router), but en0's connected v6 route is interface-scoped while VPN is primary, so bare ULA addresses fail from unbound sockets; link-local + zone or `.local` names are the reliable path.
