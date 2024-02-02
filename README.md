# Taildock

An unofficial GUI wrapper around the Tailscale CLI.

Taildock is an unofficial GUI wrapper around the Tailscale CLI client, particularly for use on Elementary OS, as no official Linux GUI client exists. It provides a dock icon and a fairly comprehensive UI with support for configuring Tailscale's features.

Taildock interfaces with the Tailscale daemon, `tailscaled`, to perform many of its operations. In order for this to work, the daemon must have been configured with the current user as the "operator". To do this, run `sudo tailscale set --operator=$USER` from the command-line at least once manually.