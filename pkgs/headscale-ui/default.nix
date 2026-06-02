{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "headscale-ui";
  version = "2026.03.17";
  src = fetchurl {
    url = "https://github.com/gurucomputing/headscale-ui/releases/download/2026.03.17/headscale-ui.zip";
    sha256 = "sha256-6Vnd6DVpIzqGQ5F+XFj1lrQzcJVWuG+emYxynQGmyyk=";
  };

  nativeBuildInputs = [unzip];

  installPhase = ''
    runHook preInstall
    unzip ${src}
    mkdir -p $out/web
    cp -r web/* $out/web/
    runHook postInstall
  '';

  meta = with lib; {
    description = "A web frontend for the headscale Tailscale-compatible coordination server";
    homepage = "https://github.com/gurucomputing/headscale-ui";
    license = licenses.free;
    platforms = ["x86_64-linux"];
    maintainers = [atp];
  };
}
