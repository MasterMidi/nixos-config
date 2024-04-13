#! /usr/bin/env sh
eza --tree --level 4 "$(nix build nixpkgs#"$1" --print-out-paths --no-link)"
