This is a bit of a primer on the nix stuff. I'm sure there's a lot here that's wrong but we can learn as we go!

- [] Crypto (might want to do manually):
  - udev rules
  - Suites
  - XX Wallet might be best
- [] Configure user profile
- [] Background image
  - copy across
- [x] Copilot
- [] Power & hibernation
- [] Btrfs snapshots (& test)
- More Nixvim:
  - [x] Solidity setup
    - [x] basic LSP
    - [x] GD
    - [x] rn
    - [x] GD to imports (might depend on project)
  - [x] Split buffers and use tabs
  - [x] navigate between windows
  - [] session that actually works
- [x] Configure VS Code & extensions if needed
- [] Figure out separate profile for Mixxx
- [x] Turn off cmp for markdown as it's annoying
- [x] Hook up to external display
- [] Have a shell that uses vim motions better
  - [] zsh - need to set fg
  - [x] tmux
- [] ssh
  - [] Good local ssh setup
  - [] Prevent standby
  - [] change hostnames to make it a bit easier

## Ultimate workflow

## Ricing

Once the workflow is sorted with gnome for things like tailscale and tmux, we can explore using hyprland and enable vim motions across the whole VM.

# BASICS

You have a copy of the nix files in 2 places:

/etc/nixos
~/.nix/ we keep stuff here to keep it out of root stuff

You can run using the nix command:

```sh
sudo nixos-rebuild switch --flake ~/.nix#default
```

(which I have aliased to `nixup`)

don't use home-manager as we are seeing this as a complete system.

On home manager you have:

- pkgs (these are system packages you can install in home.nix)
- Home manager packages (these have home-manager config settings)

Example: trash-cli you need to do at the top of home.nix

# Gnome

Gnome extensions need a few things

1. Install the extension as a package in home.nix
2. Add the extension UUID to enable it
3. Config the extension by exporting dconf - someone in github has a tool to convert to home manager
4. Log back in if you need to activate a new extension as we can't reload the shell in wayland - TBC about X

# Flakes and Nixvim

Not super clear from the docs but nixvim needs to be installed as a flake to be accessible by home manager, then you can configure it

# foundry

Forge is extremely tricky as:

- It aint a nixpkg
- It's hard to install due to some issues with solc binaries

There's a flake that takes care of the forge installation that's been added to flake.nix

# Post install steps

On a fresh profile, there are some manual steps you'll need to take:

- [] Setup Hardware config for the specific machine
  - [] There are sample config files in the [Hardware directory](./devices)
  - [] You need to add the /etc/machine_id to flake.nix to dynamically switch
- [] Sync Brave profiles -> easiest to do this manually and takes a few minutes
- [] Authorize Bitwarden, Github
- [] Login to Google accounts where relevant
- [] Login to copilot using :Copilot
- [] Install npm globals (TODO: fix [see below](#npm-globals))

# NPM Globals

Atm we have an issue that NPM globals not available as packages can't easily be added.
We fix this by allowing globals to be installed in /home and changing the npm path.

There's a startup script that runs but if you enable it, it will run on boot every time - this adds ~5mins to boot.
We can conditionally run it but some issues with that. For now you can just run the command as it's 1 package but as this grows we will
need a proper solution.

-- os

206 2024-08-10 00:18:28  
207 2024-08-10 00:19:19

-- hm

162 2024-08-10 00:18:31  
163 2024-08-10 00:19:32
