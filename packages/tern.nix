{
  lib,
  stdenv,
  stdenvNoCC,
  requireFile,
  undmg,
  autoPatchelfHook,
}:
let
  archives = {
    aarch64-darwin = {
      platform = "macos-arm64.dmg";
      hash = "sha256-XLGRQMF9m0bKRLbp1eLObMDYLcOW04h0dVaKij/FR6A=";
    };
    x86_64-linux = {
      platform = "linux-x86_64.tar.gz";
      hash = "sha256-vMICgHolxxhYVhofV+A95F+94ZE4STAuNKLwo2xs/nk=";
    };
    aarch64-linux = {
      platform = "linux-arm64.tar.gz";
      hash = "sha256-vhMzUIc1pAzpQdde6anQDfgc/Oio8JIMyp0OqjJCX0U=";
    };
  };
  archive = archives.${stdenv.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tern";
  version = "0.8.3";

  src = requireFile {
    name = "Tern-${finalAttrs.version}-${archive.platform}";
    inherit (archive) hash;
    message = ''
      Place Tern ${finalAttrs.version}'s archive in assets, then run:
        just tern-prefetch ${stdenv.hostPlatform.system}
    '';
  };

  nativeBuildInputs = if stdenv.hostPlatform.isDarwin then [ undmg ] else [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];
  sourceRoot = if stdenv.hostPlatform.isDarwin then "." else "tern";
  dontBuild = true;
  dontFixup = stdenv.hostPlatform.isDarwin;

  installPhase = ''
    runHook preInstall
    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          mkdir -p "$out/Applications" "$out/bin"
          cp -R Tern.app "$out/Applications/"
          ln -s "$out/Applications/Tern.app/Contents/MacOS/tern" "$out/bin/tern"
        ''
      else
        ''
          install -Dm755 tern "$out/bin/tern"
        ''
    }
    runHook postInstall
  '';

  meta = {
    mainProgram = "tern";
    platforms = builtins.attrNames archives;
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
