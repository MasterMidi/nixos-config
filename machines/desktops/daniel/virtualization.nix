{...}: {
  boot.kernelModules = ["kvm-amd"];
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
}
