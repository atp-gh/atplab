{config, ...}: let
  cfg = config.services.linkwarden;
in {
  sops.secrets.octopus-linkwarden-env = {
    mode = "0400";
    owner = cfg.user;
    group = cfg.group;
    format = "binary";
    sopsFile = ../secrets/linkwarden-env;
  };
  services = {
    linkwarden = {
      enable = true;
      database.createLocally = true;
      # enableRegistration = true;
      host = "127.0.0.1";
      port = 3004;
      environmentFile = config.sops.secrets.octopus-linkwarden-env.path;
    };
    nginx.virtualHosts."linkwarden.0pt.dpdns.org" = {
      forceSSL = true;
      kTLS = true;
      sslCertificate = "/etc/nginx/self-sign.crt";
      sslCertificateKey = "/etc/nginx/self-sign.key";
      extraConfig = ''
        proxy_hide_header X-Powered-By;
        proxy_hide_header Server;
      '';
      locations."/" = {
        proxyPass = "http://unix:${config.services.anubis.instances.linkwarden.settings.BIND}:";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_buffering off;
          client_max_body_size 100m;
        '';
      };
    };
    anubis.instances.linkwarden.settings = {
      TARGET = "http://${cfg.host}:${toString cfg.port}";
      BIND = "/run/anubis/anubis-linkwarden/anubis-linkwarden.sock";
      METRICS_BIND = "/run/anubis/anubis-linkwarden/anubis-linkwarden-metrics.sock";
    };
  };
}
