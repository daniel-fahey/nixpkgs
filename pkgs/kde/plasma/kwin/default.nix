{
  mkKdeDerivation,
  pkg-config,
  qtquick3d,
  qtsensors,
  qttools,
  qtvirtualkeyboard,
  qtwayland,
  libinput,
  xorg,
  xwayland,
  libcanberra,
  libdisplay-info,
  libei,
  libgbm,
  lcms2,
  pipewire,
  krunner,
  python3,
  fetchpatch,
}:
mkKdeDerivation {
  pname = "kwin";

  patches = [
    # Follow symlinks when searching for aurorae configs
    # FIXME(later): upstream?
    ./0001-follow-symlinks.patch
    # The rest are NixOS-specific hacks
    ./0003-plugins-qpa-allow-using-nixos-wrapper.patch
    ./0001-NixOS-Unwrap-executable-name-for-.desktop-search.patch
    ./0001-Lower-CAP_SYS_NICE-from-the-ambient-set.patch

    # Backport crash fix
    # FIXME: remove in 6.3.5
    (fetchpatch {
      url = "https://invent.kde.org/plasma/kwin/-/commit/93bf2f98ae22e654d997c7140b7fe9936fa3f2d3.patch";
      hash = "sha256-Jaa7IVuYMfxzUv0y2rUo5hdYavjaUkEW9/yteL5katE=";
    })
  ];

  postPatch = ''
    patchShebangs src/plugins/strip-effect-metadata.py
  '';

  # TZDIR may be unset when running through the kwin_wayland wrapper,
  # but we need it for the lockscreen clock to render
  qtWrapperArgs = [
    "--set-default TZDIR /etc/zoneinfo"
  ];

  extraNativeBuildInputs = [
    pkg-config
    python3
  ];
  extraBuildInputs = [
    qtquick3d
    qtsensors
    qttools
    qtvirtualkeyboard
    qtwayland

    krunner

    libgbm
    lcms2
    libcanberra
    libdisplay-info
    libei
    libinput
    pipewire

    xorg.libxcvt
    # we need to provide this so it knows our xwayland supports new features
    xwayland
  ];
}
