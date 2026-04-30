_: {
  virtualisation.oci-containers.containers."myapp" = {
    image = "localhost/myapp:0.1";
    volumes = [
      "myapp:/data:rw"
    ];
    ports = [
      "127.0.0.1:8001:8080"
    ];
  };
  services = {
    nginx.virtualHosts."liteos.0pt.icu" = {
      forceSSL = true;
      kTLS = true;
      sslCertificate = "/etc/nginx/self-sign.crt";
      sslCertificateKey = "/etc/nginx/self-sign.key";
      extraConfig = ''
        proxy_hide_header X-Powered-By;
        proxy_hide_header Server;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8001";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
  };
}
