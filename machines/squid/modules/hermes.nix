{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cargo
    go
  ];
  services.hermes-agent = {
    enable = true;
    container.enable = false;
    mcpServers = {
      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      };
    };
    configFile = "/etc/hermes/config.yaml";
    addToSystemPackages = true;
    # extraArgs = ["--verbose"];
    restart = "always";
    restartSec = 5;
  };
  services.hermes-agent-dashboard = {
    enable = false;
    # package = pkgs.hermes-agent;
    host = "127.0.0.1";
    # port = 9119;
    insecure = true;
    tui = false;
    # skipBuild = false;
  };
}
