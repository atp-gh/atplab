{config, ...}: {
  sops.secrets.nautilus-vexgo-env = {
    mode = "0400";
    format = "binary";
    sopsFile = ../secrets/vexgo-env;
  };
  virtualisation.oci-containers.containers."vexgo" = {
    pull = "newer";
    image = "ghcr.io/weimm16/vexgo:latest";
    environmentFiles = [config.sops.secrets.nautilus-vexgo-env.path];
    volumes = [
      "vexgo:/app/data:rw"
    ];
    ports = [
      "127.0.0.1:3001:3001"
    ];
  };
  services = {
    nginx.virtualHosts."demo.vexgo.us.ci" = {
      forceSSL = true;
      kTLS = true;
      sslCertificate = "/etc/nginx/self-sign.crt";
      sslCertificateKey = "/etc/nginx/self-sign.key";
      extraConfig = ''
        proxy_hide_header X-Powered-By;
        proxy_hide_header Server;
      '';
      locations."/" = {
        proxyPass = "http://unix:${config.services.anubis.instances.vexgo.settings.BIND}:";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
    anubis.instances.vexgo.settings = {
      TARGET = "http://127.0.0.1:3001";
      BIND = "/run/anubis/anubis-vexgo/anubis-vexgo.sock";
      METRICS_BIND = "/run/anubis/anubis-vexgo/anubis-vexgo-metrics.sock";
    };
  };
}
