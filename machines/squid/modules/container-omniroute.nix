{config, ...}: {
  sops.secrets.squid-omniroute-env = {
    mode = "0400";
    format = "binary";
    sopsFile = ../secrets/omniroute-env;
  };
  virtualisation.oci-containers.containers."omniroute" = {
    pull = "newer";
    image = "diegosouzapw/omniroute:latest";
    environmentFiles = [config.sops.secrets.squid-omniroute-env.path];
    volumes = [
      "omniroute:/app/data:rw"
    ];
    ports = [
      "127.0.0.1:20128:20128"
    ];
    labels = {
      "glance.name" = "OmniRoute";
      "glance.icon" = "sh:omniroute";
      "glance.description" = "Connect every AI tool to 265 providers — 90+ free — through one endpoint.";
    };
  };
  services.nginx.virtualHosts."omniroute.0pt.dpdns.org" = {
    forceSSL = true;
    kTLS = true;
    sslCertificate = "/etc/nginx/self-sign.crt";
    sslCertificateKey = "/etc/nginx/self-sign.key";
    extraConfig = ''
      proxy_hide_header X-Powered-By;
      proxy_hide_header Server;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:20128";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_buffering off;
      '';
    };
  };
}
