{
  lib,
  borgmatic,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "prometheus-borgmatic-exporter";
  version = "0.2.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "maxim-mityutko";
    repo = "borgmatic-exporter";
    tag = "v${version}";
    hash = "sha256-/d9XX/7w6hod7udB9tlCqOVpcpWZzU0Kir9RSoQiQBs=";
  };

  pythonRelaxDeps = [ "prometheus-client" ];

  build-system = with python3Packages; [ poetry-core ];

  propagatedBuildInputs =
    [ borgmatic ]
    ++ (with python3Packages; [
      arrow
      click
      flask
      loguru
      pretty-errors
      prometheus-client
      timy
      waitress
    ]);

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-mock
  ];

  meta = with lib; {
    description = "Prometheus exporter for Borgmatic";
    homepage = "https://github.com/maxim-mityutko/borgmatic-exporter";
    changelog = "https://github.com/maxim-mityutko/borgmatic-exporter/releases/tag/${src.tag}";
    license = licenses.mit;
    maintainers = with maintainers; [ flandweber ];
    mainProgram = "borgmatic-exporter";
    platforms = platforms.unix;
  };
}
