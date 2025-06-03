{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  jansson,
  openssl,
  gnutls,
  mbedtls,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libjwt";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "benmcollins";
    repo = "libjwt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/Fm7pIlcjsAWaPUoRMOoYgUpEA+AwWzOuGgxVjiHjNc=";
  };

  buildInputs = [
    jansson
    openssl
    gnutls
    mbedtls
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  meta = with lib; {
    homepage = "https://github.com/benmcollins/libjwt";
    description = "JWT C Library";
    license = licenses.mpl20;
    maintainers = with maintainers; [ pnotequalnp ];
    platforms = platforms.all;
  };
})
