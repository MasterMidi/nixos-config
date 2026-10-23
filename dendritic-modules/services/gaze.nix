{ self, ... }:
{
  flake.nixosModules.gaze =
    { inputs, config, ... }:
    {
      imports = [ inputs.gaze.nixosModules.default ];

      services.gaze = {
        enable = true;
        gui.enable = true;
        gnome.enable = true; # needed ofr gnome-keyring functionality
        gnome.gdmFaceLogin = config.services.displayManager.gdm.enable;

        mutableConfig = false;
        settings = {
          inference = {
            execution_provider = "cpu";
            device = "cpu";
          };
          security.level = "medium";
          cameras = {
            rgb = "primary";
            ir = "pipewiresrc target-object=v4l2_input.pci-0000_03_00.3-usb-0_3_1.2";
            emitter_enabled = true; # needed for IR camera to work
            parallel_capture = "auto";
          };
          liveness = {
            enabled = true;
            max_seconds = 2.0;
            threshold = 0.8;
          };
          storage = {
            encrypt_templates = true;
            unlock_gnome_keyring = config.services.gnome.gnome-keyring.enable;
          };
        };
      };

      security.pam.services.hyprlock.gaze.enable = true;

      # enable tpm to use encrypt_templates in Gaze
      security.tpm2.enable = true;

      users.users.michael.extraGroups = [ "tss" ];
    };

    flake.nixosModules.gaze-zenith =
      { inputs, config, ... }:
      {
        imports = [ inputs.gaze.nixosModules.default ];

        services.gaze = {
          enable = true;
          gui.enable = true;
          gnome.enable = true; # needed ofr gnome-keyring functionality
          gnome.gdmFaceLogin = config.services.displayManager.gdm.enable;

          mutableConfig = true;
          settings = {
            inference = {
              execution_provider = "cpu";
              device = "cpu";
            };
            security.level = "medium";
            cameras = {
              rgb = "primary";
              ir = "pipewiresrc target-object=v4l2_input.pci-0000_0c_00.0-usb-0_10_1.2";
              emitter_enabled = true; # needed for IR camera to work
              parallel_capture = "auto";
            };
            liveness = {
              enabled = true;
              max_seconds = 2.0;
              threshold = 0.8;
            };
            storage = {
              encrypt_templates = true;
              unlock_gnome_keyring = config.services.gnome.gnome-keyring.enable;
            };
          };
        };

        security.pam.services.hyprlock.gaze.enable = true;

        # enable tpm to use encrypt_templates in Gaze
        security.tpm2.enable = true;

        users.users.michael.extraGroups = [ "tss" ];
      };
}
