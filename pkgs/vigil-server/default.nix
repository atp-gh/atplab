{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  glibc,
  gnutar,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "vigil-server";
  version = "3.3.1";
  src = fetchurl {
    url = "https://github.com/pineappledr/vigil/releases/download/v3.3.1/vigil-server-linux-amd64";
    sha256 = "sha256-D8/kjZOV6/A7Qxib5rYBVmZIy37XWVfzHiyi1A39fuw=";
  };
  web = fetchurl {
    url = "https://github.com/pineappledr/vigil/archive/refs/tags/v3.3.1.tar.gz";
    sha256 = "sha256-bnZAomu1XlpNE/qTUMLbcTDUgVbkWvRoFg3OYLRMlng=";
  };
  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [glibc gnutar];
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/web
    cp $src $out/bin/vigil-server
    chmod +x $out/bin/vigil-server
    tar -xzf $web
    cp -r vigil-3.3.1/web/* $out/web/
    runHook postInstall
  '';
  meta = with lib; {
    description = "Vigil is a modern, lightweight, and open-source server monitoring system, that provides real-time S.M.A.R.T. health tracking.";
    homepage = "https://github.com/pineappledr/vigil";
    license = licenses.free;
    platforms = ["x86_64-linux"];
    maintainers = [atp];
  };
}
