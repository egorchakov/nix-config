{
  lib,
  stdenv,
  zig_0_17,
  makeBinaryWrapper,
  gitMinimal,
  src,
}:
stdenv.mkDerivation {
  pname = "git-blame-lsp";
  version = "unstable-${src.shortRev}";
  inherit src;
  nativeBuildInputs = [
    zig_0_17.hook
    makeBinaryWrapper
  ];
  postFixup = ''
    wrapProgram $out/bin/git-blame-lsp \
      --prefix PATH : ${lib.makeBinPath [ gitMinimal ]}
  '';
  meta.mainProgram = "git-blame-lsp";
}
