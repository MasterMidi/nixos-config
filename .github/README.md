<div align="center">
<img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake-colours.svg" width="96px" height="96px" />

[![](https://readme-typing-svg.demolab.com/?font=JetBrains+Mono&size=32&duration=3000&pause=1000&color=EBDBB2&center=true&vCenter=true&random=false&width=435&lines=My+NixOS+config)](https://git.io/typing-svg)

<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="600px" /> <br>

<!-- spacer -->
<p></p>
<a href="https://github.com/MasterMidi/nixos-config/issues">
<img src="https://img.shields.io/github/issues/MasterMidi/nixos-config?color=d8a657&labelColor=32302f&style=for-the-badge">
</a>
<a href="https://github.com/MasterMidi/nixos-config/stargazers">
<img src="https://img.shields.io/github/stars/MasterMidi/nixos-config?color=d3869b&labelColor=32302f&style=for-the-badge">
</a>
<a href="https://github.com/MasterMidi/nixos-config/">
<img src="https://img.shields.io/github/repo-size/MasterMidi/nixos-config?color=ea999c&labelColor=32302f&style=for-the-badge">
</a>
<a href="https://github.com/MasterMidi/nixos-config/blob/main/LICENSE">
<img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=GPL-3&logoColor=d3869b&colorA=313244&colorB=cba6f7"/>
</a>
<a href="https://nixos.org">
<img src="https://img.shields.io/badge/NixOS-unstable-blue.svg?style=for-the-badge&labelColor=32302f&logo=NixOS&logoColor=white&color=7daea3">
</a>
<a href="https://nixos.org">
<img src="https://img.shields.io/github/last-commit/shvedes/dotfiles?style=for-the-badge&color=d8a657&labelColor=32302f">
</a>
<br>
</div>

# Building

There are several ways to build these system, depending on what is required.

## Building sd-card image (Raspberry Pi)

To build the sd-card images for the raspberry pi systems, there is the images output. To build these use

```sh
nom build .#images.pisces
```

# Configuration structure

```sh
nixos
|- .editorconfig # standardised configuration for editor options
|- .envrc #
|- machines
  |-
```

# Development tools

these is a shell.nix provided that contains tools for working with the configurations. The shell nix can be used with direnv, with the `.envrc` file

More names for future machines: https://www.reddit.com/r/namenerds/comments/1e4ot95/space_themed_names/
