#!/usr/bin/env bash

nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=./sd-base-image.nix   --argstr system aarch64-linux   --option sandbox false
