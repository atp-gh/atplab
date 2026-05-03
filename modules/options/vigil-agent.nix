{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.vigil-agent;
  inherit
    (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    concatStringsSep
    ;
in {
  options.services.vigil-agent = {
    enable = mkEnableOption "vigil-agent";

    server = mkOption {
      type = types.str;
      default = "http://127.0.0.1:9080";
      description = "Vigil server URL.";
    };

    interval = mkOption {
      type = types.int;
      default = 60;
      description = "Reporting interval in seconds. Set to 0 to run once.";
    };

    hostname = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Override hostname reported to server.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/vigil-agent";
      description = "Directory for agent keys and state.";
    };

    listen = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Optional HTTP listen address (example :9090).";
    };

    register = mkOption {
      type = types.bool;
      default = false;
      description = "Run agent registration on startup.";
    };

    token = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "One-time registration token.";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra command line arguments.";
    };

    user = mkOption {
      type = types.str;
      default = "vigil-agent";
    };

    group = mkOption {
      type = types.str;
      default = "vigil-agent";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (_final: prev: {
        vigil-agent = prev.callPackage ../../pkgs/vigil-agent/default.nix {};
      })
    ];

    systemd.services.vigil-agent = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      description = "Vigil Agent";

      path = [pkgs.smartmontools];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;

        ExecStart = concatStringsSep " " (
          [
            "${pkgs.vigil-agent}/bin/vigil-agent"
            "-server ${cfg.server}"
            "-interval ${toString cfg.interval}"
            "-data-dir ${cfg.dataDir}"
          ]
          ++ lib.optional (cfg.hostname != null) "-hostname ${cfg.hostname}"
          ++ lib.optional (cfg.listen != null) "-listen ${cfg.listen}"
          ++ lib.optional cfg.register "-register"
          ++ lib.optional (cfg.token != null) "-token ${cfg.token}"
          ++ cfg.extraFlags
        );

        Restart = "on-failure";
        RestartSec = 5;

        StateDirectory = "vigil-agent";
        RuntimeDirectory = "vigil-agent";
        SyslogIdentifier = "vigil-agent";
      };
    };

    users.users = mkIf (cfg.user == "vigil-agent") {
      vigil-agent = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
      };
    };

    users.groups = mkIf (cfg.group == "vigil-agent") {
      vigil-agent = {};
    };
  };
}
