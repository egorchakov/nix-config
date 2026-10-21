{
  fetchurl,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rerun-bin";
  version = "0.40.0";

  src = fetchurl {
    url = "https://github.com/rerun-io/rerun/releases/download/${finalAttrs.version}/rerun-cli-${finalAttrs.version}-${stdenvNoCC.hostPlatform.rust.rustcTarget}";
    hash = "sha256-6rW7gzJ9SvO2DrDSRGJMGQd/GalOJh/w/apWzALH8tI=";
  };

  dontUnpack = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/rerun"

    runHook postInstall
  '';

  meta = {
    description = "Rerun Viewer and CLI, official prebuilt binary";
    homepage = "https://rerun.io";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "rerun";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
