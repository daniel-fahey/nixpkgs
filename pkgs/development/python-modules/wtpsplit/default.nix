{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  transformers,
  huggingface-hub,
  numpy,
  scikit-learn,
  tqdm,
  skops,
  pandas,
  cached-property,
  mosestokenizer,
  # adapters,

  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "wtpsplit";
  version = "2.1.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "segment-any-text";
    repo = "wtpsplit";
    tag = "${version}";
    hash = "sha256-xCNSbThcKuH5fa9zzZX1oKrMmf5lZVS1zODEUlJ0BGc=";
  };

  build-system = [
    setuptools
  ];

  # pythonRelaxDeps = [
  #   "av"
  #   "tokenizers"
  # ];

  dependencies = [
    transformers
    huggingface-hub
    numpy
    scikit-learn
    tqdm
    skops
    pandas
    cached-property
    mosestokenizer
    adapters
  ];

  pythonImportsCheck = [ "wtpsplit" ];

  doCheck = true;

  nativeCheckInputs = [ pytestCheckHook ];

  # preCheck = ''
  #   export HOME=$TMPDIR
  # '';

  meta = with lib; {
    changelog = "https://github.com/${src.owner}/${src.repo}/releases/tag/${src.tag}";
    description = "Toolkit to segment text into sentences or other semantic units in a robust, efficient and adaptable way";
    homepage = "https://github.com/${src.owner}/${src.repo}";
    license = licenses.mit;
    maintainers = with maintainers; [ daniel-fahey ];
  };
}
