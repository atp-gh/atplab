{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    codex
    nodejs_26
    bun
  ];
}
