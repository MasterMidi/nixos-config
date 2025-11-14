{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.flakeModules
    ./deploy-rs
  ];
  flake.flakeModule = {
    deploy-rs = ./deploy-rs;
  };

}
