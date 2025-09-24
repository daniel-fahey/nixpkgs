{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  transformers,
  torch,


  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "adapters";
  version = "1.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "adapter-hub";
    repo = "adapters";
    tag = "v${version}";
    hash = "sha256-LCXmO3w4jsqnaMXDfD3gHDyuTIUFrfQ/CnFYQgIkcjk=";
  };

  build-system = [
    setuptools
  ];

  pythonRelaxDeps = [
    # "av"
    # "tokenizers"
    "transformers"
  ];

  dependencies = [
    transformers
    torch

  ];

  pythonImportsCheck = [ "adapters" ];

  doCheck = true;

  nativeCheckInputs = [ pytestCheckHook ];

  # preCheck = ''
  #   export HOME=$TMPDIR
  # '';

  meta = {
    changelog = "https://github.com/${src.owner}/${src.repo}/releases/tag/v${src.tag}";
    description = "A Unified Library for Parameter-Efficient and Modular Transfer Learning ";
    homepage = "https://github.com/${src.owner}/${src.repo}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ daniel-fahey ];
  };
}
