{
  fetchurl,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rerun-bin";
  version = "0.43.1";

  src = fetchurl {
    url = "https://github.com/rerun-io/rerun/releases/download/${finalAttrs.version}/rerun-cli-${finalAttrs.version}-${stdenvNoCC.hostPlatform.rust.rustcTarget}";
    hash = "sha256-O627sx0CYzZv49/1LqMbbH/KCq+OjCvU7phev/fmIRk=";
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
