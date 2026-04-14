# Based on the arch wiki guide: https://wiki.archlinux.org/title/Lenovo_IdeaPad_Slim_3_16ABR8

{ ... }:
{
  flake.nixosModules.lenovo-yoga-7-14ARH7-power-management =
    { config, pkgs, ... }:

    let
      lenovo-power-menu = pkgs.writeShellApplication {
        name = "lenovo-power-menu";
        # We declare gum and coreutils as runtime dependencies.
        # They are available strictly to this script without polluting the global system PATH.
        runtimeInputs = [
          pkgs.gum
          pkgs.coreutils
        ];

        text = ''
          set -euo pipefail

          # 1. Enforce Root Privileges
          if [ "$EUID" -ne 0 ]; then
            gum style --foreground 196 "Error: This script must be run as root (sudo)."
            exit 1
          fi

          # 2. Ensure ACPI Call interface is available
          if [ ! -f /proc/acpi/call ]; then
            gum style --foreground 196 "Error: /proc/acpi/call not found. Ensure the acpi_call module is loaded."
            exit 1
          fi

          # Helper function to cleanly send ACPI commands
          acpi_cmd() {
            echo "$1" > /proc/acpi/call
          }

          gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Lenovo Power Management"

          while true; do
            ACTION=$(gum choose "Performance Mode" "Battery Features" "Exit")

            case "$ACTION" in
              "Performance Mode")
                MODE=$(gum choose "Intelligent Cooling" "Extreme Performance" "Battery Saving" "Back")
                case "$MODE" in
                  "Intelligent Cooling")
                    acpi_cmd '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001'
                    gum style --foreground 78 "Applied: Intelligent Cooling."
                    ;;
                  "Extreme Performance")
                    acpi_cmd '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001'
                    gum style --foreground 78 "Applied: Extreme Performance."
                    ;;
                  "Battery Saving")
                    acpi_cmd '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001'
                    gum style --foreground 78 "Applied: Battery Saving."
                    ;;
                esac
                ;;
              "Battery Features")
                # Handling the mutual exclusivity rule outlined in the Arch Wiki
                FEAT=$(gum choose "Enable Rapid Charge" "Enable Battery Conservation" "Disable Both" "Back")
                case "$FEAT" in
                  "Enable Rapid Charge")
                    # Explicitly disable Conservation mode first to avoid straining the battery
                    acpi_cmd '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' # Conservation OFF
                    acpi_cmd '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x07' # Rapid ON
                    gum style --foreground 78 "Rapid Charge Enabled. Battery Conservation is now OFF."
                    ;;
                  "Enable Battery Conservation")
                    # Explicitly disable Rapid Charge first
                    acpi_cmd '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' # Rapid OFF
                    acpi_cmd '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x03' # Conservation ON
                    gum style --foreground 78 "Battery Conservation Enabled (55-60%). Rapid Charge is now OFF."
                    ;;
                  "Disable Both")
                    acpi_cmd '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' # Rapid OFF
                    acpi_cmd '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' # Conservation OFF
                    gum style --foreground 78 "Both features disabled. Standard charging is active."
                    ;;
                esac
                ;;
              "Exit")
                gum style --foreground 212 "Exiting."
                break
                ;;
            esac
          done
        '';
      };
    in
    {
      # Load the acpi_call kernel module at boot
      boot.kernelModules = [ "acpi_call" ];
      boot.kernelParams = [ "ideapad_laptop.allow_v4_dytc=1" ];

      # Ensure the acpi_call package matching your specific kernel version is built and available
      boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

      # Add our packaged script to the system environment
      environment.systemPackages = [
        lenovo-power-menu
      ];
    };
}
