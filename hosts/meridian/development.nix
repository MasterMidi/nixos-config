{ self, ... }:
{
  imports = [
    self.modules.nixos.development
  ];

  development = {
    android = {
      enable = true;
    };
  };
}
