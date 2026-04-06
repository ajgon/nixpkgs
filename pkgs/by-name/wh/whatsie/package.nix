{
  fetchFromGitHub,
  lib,
  stdenv,
  cmake,
  qt6,
  linkFarm,
  hunspellDictsChromium,
  dictionaries ? [
    hunspellDictsChromium.en-us
  ],
}:

let
  qtwebengineDictionaries = linkFarm "whatsie-qtwebengine-dictionaries" (
    map (d: {
      name = d.dictFileName;
      path = d;
    }) dictionaries
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "whatsie";
  version = "6.0.3";

  src = fetchFromGitHub {
    owner = "keshavbhatt";
    repo = "whatsie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vT5Oopkc2rF0+d8E+KuOXIoGAr1abO4yRdnJ9UfG6P8=";
  };

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
    qt6.qtwebengine
  ];

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  strictDeps = true;

  enableParallelBuilding = true;

  doCheck = true;

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  checkPhase = ''
    runHook preCheck

    ctest --output-on-failure --exclude-regex '^tst_permissions$'

    runHook postCheck
  '';

  preFixup = lib.optionalString (dictionaries != [ ]) ''
    qtWrapperArgs+=(
      --set-default QTWEBENGINE_DICTIONARIES_PATH "${qtwebengineDictionaries}"
    )
  '';

  meta = {
    homepage = "https://github.com/keshavbhatt/whatsie";
    description = "Feature rich WhatsApp Client for Desktop Linux";
    license = lib.licenses.mit;
    mainProgram = "whatsie";
    maintainers = with lib.maintainers; [ ajgon ];
    platforms = lib.platforms.linux;
  };
})
