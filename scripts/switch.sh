#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

if [ "$EUID" -ne 0 ]; then
	echo "󰣮 Please run as root"
	exit
fi

echo "${bold}⚗️  Testing Configuration ${normal}"
case "$OSTYPE" in
linux*) nixos-rebuild dry-build --impure ;;
*) echo "unknown: $OSTYPE" ;;
esac

if [ $? -eq 0 ]; then
	echo "🔨 Rebuilding Configuration…"
	case "$OSTYPE" in
	linux*) nixos-rebuild switch --impure ;;
	*) echo "unknown: $OSTYPE" ;;
	esac
	if [ $? -eq 0 ]; then
		echo "❄️ Done! NixOS is Now Running Generation $(nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')."
	fi
else
	echo "🚨 Could Not Build Configuration…"
fi
