{config, ...}: let
  cfg = config.services.goatcounter;
in {
  services = {
    goatcounter = {
      enable = true;
      address = "127.0.0.1";
      port = 8084;
      proxy = true;
      extraArgs = ["-email-from" "admin@localhost"];
    };
    nginx.virtualHosts."goatcounter.0pt.dpdns.org" = {
      forceSSL = true;
      kTLS = true;
      sslCertificate = "/etc/nginx/self-sign.crt";
      sslCertificateKey = "/etc/nginx/self-sign.key";
      extraConfig = ''
        proxy_hide_header X-Powered-By;
        proxy_hide_header Server;
      '';
      locations."/" = {
        proxyPass = "http://${cfg.address}:${toString cfg.port}";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
  };
}
