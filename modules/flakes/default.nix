{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.flakeModules
    ./deploy-rs
  ];
  flake.flakeModules = {
    deploy-rs = ./deploy-rs;
  };

}
