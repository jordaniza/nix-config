This is a bit of a primer on the nix stuff. I'm sure there's a lot here that's wrong but we can learn as we go!

# TODO

- [] Configure VS Code extensions
- [x] Configure brave profiles
    (Manual)
- [] Crypto (might want to do manually):
  - Frame
  - Trezor Suite
  - Ledger
  - udev rules
- [x] Configure GTILE
- [x] Configure keyboard shortcuts
   - need to add pop shell
- [] Configure the terminal appearance
- [] Configure user profile
- [x] Background image
   - not worth it
- [x] Connect Git to Github
- [] Copilot
- [x] Apps:
  - Discord
  - Telegram
- Basic neovim that I like
  - [x] RLN
  - [] Transparency
  - [] Treesitter
    - [] Some LSPs

- [] Understand imports and better structure code

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


# Post install steps

On a fresh profile, there are some manual steps you'll need to take:

- [] Setup Hardware config for the specific machine
- [] Sync Brave profiles -> easiest to do this manually and takes a few seconds
- [] Authorize Bitwarden, Github
- [] Login to Google accounts where relevant
