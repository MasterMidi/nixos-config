{
  lib,
  python312Packages,
  fetchFromGitHub,
}:
python312Packages.buildPythonApplication rec {
  pname = "qbitmanage";
  version = "4.1.7";

  src = fetchFromGitHub {
    owner = "StuffAnThings";
    repo = "qbit_manage";
    rev = "v${version}";
    sha256 = "sha256-YIw5iuwQq9UX6htRvfYaKDxP6MmkNGHwJ/IKeYHr60c=";
  };

  # build-system = with python312Packages; [
  #   setuptools
  #   setuptools-scm
  # ];

  propagatedBuildInputs = with python312Packages; [
    bencode-py
    croniter
    GitPython
    humanize
    pytimeparse2
    qbittorrent-api
    requests
    retrying
    ruamel-yaml
    schedule
  ];

  # doCheck = false;

  nativeCheckInputs = with python312Packages; [
    pytest
    flake8
  ];

  postInstall = ''
    mkdir -p $out/bin
    cp qbit_manage.py $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/StuffAnThings/qbit_manage";
    description = "A tool to manage torrent and automate qBittorrent";
    license = licenses.mit;
    maintainers = ["MasterMidi"];
  };
}
