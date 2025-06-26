# /etc/nixos/configuration.nix

{ config, pkgs, ... }:

{
  # ... your other nixos configuration options

  systemd.services.update-qbit-vpn-ip-on-kuma = {
    description = "Fetch VPN container IP and push to Uptime Kuma";
    serviceConfig.Type = "oneshot";
    after = [ config.virtualisation.oci-containers.compose.mediaserver.container.qbit.unitName ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      podman
      curl
      coreutils
    ];

    script = ''
      set -e # Exit immediately if a command in the final part fails.

      # --- CONFIGURATION ---
      CONTAINER_NAME=${config.virtualisation.oci-containers.compose.mediaserver.container.qbit.containerName}
      KUMA_PUSH_URL="https://kuma.mgrlab.dk/api/push/YOUR_PUSH_TOKEN_HERE"

      # Retry configuration
      MAX_RETRIES=15          # Try a total of 15 times
      RETRY_INTERVAL=10       # Wait 10 seconds between each try
      # (Total wait time = 15 * 10 = 150 seconds, or 2.5 minutes)
      # ---------------------

      IP=""
      RETRY_COUNT=0

      echo "Attempting to fetch public IP from container '$CONTAINER_NAME'..."

      while [ -z "$IP" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "Attempt #$RETRY_COUNT/$MAX_RETRIES..."

        # Use 'podman exec' to run curl. We add '|| true' so that the script
        # doesn't exit if curl fails; we want to handle the failure inside the loop.
        IPV4=$(${pkgs.podman}/bin/podman exec "$CONTAINER_NAME" curl -4 --silent --connect-timeout 8 icanhazip.com || true)
        IPV6=$(${pkgs.podman}/bin/podman exec "$CONTAINER_NAME" curl -6 --silent --connect-timeout 8 icanhazip.com || true)

        # Check if we got a valid-looking IP (basic check for dots)
        if [[ ! "$IP" =~ \. ]]; then
          IP="" # Unset IP if it doesn't look like an IP address
        fi

        if [ -z "$IP" ]; then
          if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "Failed. Retrying in $RETRY_INTERVAL seconds..."
            sleep $RETRY_INTERVAL
          fi
        fi
      done

      # After the loop, check if we ever succeeded
      if [ -z "$IP" ]; then
        echo "Error: Could not retrieve public IP after $MAX_RETRIES attempts."
        # Optionally send a "down" status to Uptime Kuma
        MESSAGE="Failed%20to%20get%20IP%20after%20$MAX_RETRIES%20retries."
        ${pkgs.curl}/bin/curl -g -m 10 "''${KUMA_PUSH_URL}?status=down&msg=$MESSAGE"
        exit 1
      fi

      # If we get here, we have an IP
      set -e # Re-enable exit-on-error for the final part

      echo "Successfully retrieved IP: $IP"
      echo "Sending 'up' signal to Uptime Kuma..."

      MESSAGE="VPN%20IP%20is%20$IP"
      FINAL_URL="''${KUMA_PUSH_URL}?status=up&msg=$MESSAGE"

      ${pkgs.curl}/bin/curl -g --fail -m 10 "$FINAL_URL"

      echo "Uptime Kuma monitor updated successfully."
    '';
  };

  # ... your other configuration
}
