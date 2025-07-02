{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  uv-build,
  setuptools,

  # runtime-dependencies
  click,
  ipykernel,
  numpy,
  pandas-stubs,
  pandas,
  polars,
  pygments,
  rich,
  typeguard,
  pyarrow,
}:

buildPythonPackage rec {
  pname = "skimpy";
  version = "0.0.18";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "aeturrell";
    repo = "skimpy";
    tag = "v${version}";
    hash = "sha256-y6X1pI6zcilhhyOSpFSoTXw1Z6RKk8RQn31sXjBU1F4=";
  };

  build-system = [
    uv-build
    setuptools
  ];

  dependencies = [
    click
    ipykernel
    numpy
    pandas-stubs
    pandas
    polars
    pygments
    rich
    typeguard
    pyarrow
  ];

  pythonImportsCheck = [ "skimpy" ];

  meta = with lib; {
    description = "A light weight tool for creating summary statistics from dataframes";
    homepage = "https://github.com/aeturrell/skimpy";
    license = licenses.mit;
    maintainers = with maintainers; [ daniel-fahey ];
  };
}
