# Tailnet

Tailnet is an unofficial GUI wrapper around the Tailscale CLI.

A "Tailnet" is "The set of machines in a Tailscale network is referred to as a tailnet. Each machine in the tailnet is considered a node and is assigned a unique Tailscale IP address by the coordination server. Nodes can directly communicate with one another unless the traffic is restricted by the tailnet’s access control lists (ACLs)".

> Source: [Tailscale's glossary](https://tailscale.com/glossary/tailnet)

Tailnet is an unofficial GUI wrapper around the Tailscale CLI client, particularly for use on Elementary OS, as no official Linux GUI client exists. It provides a dock icon and a fairly comprehensive UI with support for configuring Tailscale's features.

Tailnet interfaces with the Tailscale daemon, `tailscaled`, to perform many of its operations. In order for this to work, the daemon must have been configured with the current user as the "operator". To do this, run `sudo tailscale set --operator=$USER` from the command-line at least once manually.

## Device List and Copy Paste Ready

![Screenshot of application with Devices in Tailnet shown in left sidebar, with detailed view of selected device on the right](Tailnet_DeviceList.png)

## Inspiration and Attribution

This application started a way to learn more about Vala and Elementary OS' application [developer docs](https://docs.elementary.io/develop/).

Ater searching what is out there already, I found [Trayscale](https://flathub.org/apps/dev.deedles.Trayscale). A big thank you and mention for the general concept and pane layout idea, but none of the source code (I don't know Go).

This application takes it's design style from the official Tailscale iOS application and Elementary's Granite library.


