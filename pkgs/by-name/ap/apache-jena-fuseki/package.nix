{
  lib,
  stdenv,
  fetchurl,
  jre,
  coreutils,
  which,
  makeWrapper,
  # For the test
  pkgs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apache-jena-fuseki";
  version = "6.2.0";

  src = fetchurl {
    url = "mirror://apache/jena/binaries/apache-jena-fuseki-${finalAttrs.version}.tar.gz";
    hash = "sha256-47iwM4cs0vJAkWA77B5+shzD4d71uVcmWMSBQ+hrl38=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    cp -r . "$out"
    mkdir -p "$out/bin"
    ln -s "$out"/{fuseki-backup,fuseki-server,fuseki-plain} "$out/bin"
    ln -s "$out/fuseki-plain" "$out/bin/fuseki"
    for i in "$out"/bin/fuseki*; do
      # It is necessary to set the default $FUSEKI_BASE directory to a writable location
      # By default it points to $FUSEKI_HOME/run which is in the nix store
      wrapProgram "$i" \
        --prefix "PATH" : "$out/bin:${jre}/bin:${coreutils}/bin:${which}/bin" \
        --set-default "FUSEKI_HOME" "$out" \
        --run "if [ -z \"\$FUSEKI_BASE\" ]; then export FUSEKI_BASE=\"\$HOME/.local/fuseki\" ; mkdir -p \"\$HOME/.local/fuseki\" ; fi" \
        ;
    done
  '';

  passthru = {
    tests = {
      basic-test = pkgs.callPackage ./basic-test.nix { };
    };
  };

  meta = {
    description = "SPARQL server";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    homepage = "https://jena.apache.org";
    downloadPage = "https://archive.apache.org/dist/jena/binaries/";
    mainProgram = "fuseki";
  };
})
