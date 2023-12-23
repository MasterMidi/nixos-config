#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}󰚰 Updating repositories ${normal}"
sudo nix flake update

echo "${bold}⚗️ Testing Configuration ${normal}"
#hyperfine --export-markdown /etc/nixos/measure.md --runs 3 "nixos-rebuild dry-activate"
case "$OSTYPE" in
  linux*)   nixos-rebuild dry-build ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

if [ $? -eq 0 ]; then
	echo "🔨 Rebuilding Configuration…"
	case "$OSTYPE" in
	  linux*)   sudo nixos-rebuild switch --upgrade ;;
	  *)        echo "unknown: $OSTYPE" ;;
	esac
	if [ $? -eq 0 ]; then
		echo "❄️ Done! NixOS is Now Running Generation $(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')."
	fi
else
	echo "🚨 Could Not Build Configuration…"
fi
