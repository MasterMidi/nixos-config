{
  python312Packages,
  fetchFromGitHub,
  lib,
}:
python312Packages.buildPythonPackage rec {
  name = "qbitmanage";
  version = "4.0.8";
  src = fetchFromGitHub {
    owner = "StuffAnThings";
    repo = "qbit_manage";
    rev = "v${version}";
    sha256 = "sha256-llJUBm3O+LDv6euuuNojTFTkR8BmmCnffkmunYL1+0s=";
  };

  propagatedBuildInputs = with python312Packages; [
    requests
    retrying
    schedule
    GitPython
    ruamel-yaml
    bencode-py
    qbittorrent-api
  ];

  doCheck = false;

  # postInstall = ''
  #   mkdir -p $out/bin
  #   cp qbit_manage.py $out/bin/qbitmanage
  #   chmod +x $out/bin/qbitmanage
  # '';

  meta = with lib; {
    homepage = "https://github.com/StuffAnThings/qbit_manage";
    description = "A tool to manage torrent and automate qBittorrent";
    license = licenses.mit;
    mainProgram = "qbitmanage";
    maintainers = with maintainers; [];
  };
}
