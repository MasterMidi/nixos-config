{
  python39Packages,
  fetchFromGitHub,
  lib,
}:
python39Packages.buildPythonApplication rec {
  name = "qbitmanage";
  version = "4.0.8";
  src = fetchFromGitHub {
    owner = "StuffAnThings";
    repo = "qbit_manage";
    rev = "v${version}";
    sha256 = "sha256-llJUBm3O+LDv6euuuNojTFTkR8BmmCnffkmunYL1+0s=";
  };

  dependencies = with python39Packages; [
    requests
    retrying
    schedule
    GitPython
    ruamel-yaml
    bencode-py
    qbittorrent-api
  ];

	postInstall = ''
    mkdir -p $out/bin
    cp qbit_manage.py $out/bin/qbitmanage
    chmod +x $out/bin/qbitmanage
  '';

  meta = with lib; {
    homepage = https://github.com/StuffAnThings/qbit_manage;
    description = "A tool to manage torrent and automate qBittorrent";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
