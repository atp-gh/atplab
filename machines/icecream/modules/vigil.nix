{
  config,
  pkgs,
  ...
}: let
  cfg = config.services.vigil-server;
in {
  environment.systemPackages = with pkgs; [zfs_2_4 nvme-cli];
  services = {
    vigil-server = {
      enable = true;
      port = 9080;
      auth.enable = false;
    };
    vigil-agent = {
      enable = true;
      # register = true;
      # token = "f6b985c74eb5acaa97fc715026b3287a673984d5c939f4fe3d4390e79964981e";
      user = "root";
      group = "root";
    };
    nginx.virtualHosts."vigil.0pt.lab" = {
      forceSSL = true;
      kTLS = true;
      sslCertificate = "/etc/nginx/self-sign.crt";
      sslCertificateKey = "/etc/nginx/self-sign.key";
      extraConfig = ''
        proxy_hide_header X-Powered-By;
        proxy_hide_header Server;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
  };
}
