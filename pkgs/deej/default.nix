# https://github.com/omriharel/deej
# https://github.com/omriharel/deej/blob/master/assets/community-builds/snackya.jpg
# https://github.com/omriharel/deej/blob/master/assets/community-builds/bgrier.jpg
{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  stdenv,
  darwin,
  gtk3,
  webkitgtk,
  libappindicator-gtk3,
}:
buildGoModule rec {
  pname = "deej";
  version = "0.9.10";

  src = fetchFromGitHub {
    owner = "omriharel";
    repo = "deej";
    rev = "v${version}";
    hash = "sha256-T6S3FQ9vxl4R3D+uiJ83z1ueK+3pfASEjpRI+HjIV0M=";
  };

  vendorHash = "sha256-1gjFPD7YV2MTp+kyC+hsj+NThmYG3hlt6AlOzXmEKyA=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Cocoa
      darwin.apple_sdk.frameworks.WebKit
    ]
    ++ lib.optionals stdenv.isLinux [
      libappindicator-gtk3
      gtk3
      webkitgtk
    ];

  ldflags = ["-s" "-w"];

  postInstall = ''
    mkdir -p $out/bin
    mv $out/bin/cmd $out/bin/deej
  '';

  meta = with lib; {
    description = "Set app volumes with real sliders! deej is an Arduino & Go project to let you build your own hardware mixer for Windows and Linux";
    homepage = "https://github.com/omriharel/deej";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "deej";
  };
}
