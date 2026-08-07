_: {
  # https://docs.hoppscotch.io/documentation/self-host/community-edition/install-and-build#migrations
  # Should run this command to migrations database
  # podman run --rm -it --entrypoint sh --env-file /run/secrets/squid-hoppscotch-env hoppscotch/hoppscotch
  # /dist/backend # pnpm prisma migrate deploy
  virtualisation.oci-containers.containers."hoppscotch" = {
    pull = "newer";
    # Use aio image
    image = "hoppscotch/hoppscotch:latest";
    environment = {
      "DATABASE_URL" = "postgresql://user:passwd@host:5432/dbname";
      # Sensitive Data Encryption Key while storing in Database (32 character)
      "DATA_ENCRYPTION_KEY" = "data encryption key with 32 char";

      "WHITELISTED_ORIGINS" = "https://hoppscotch.example.com,http://localhost:3170,http://localhost:3000,http://localhost:3100,app://localhost_3200,app://hoppscotch";
      "TRUST_PROXY" = "true";
      "ENABLE_SUBPATH_BASED_ACCESS" = "true";

      "VITE_BASE_URL" = "https://hoppscotch.example.com";
      "VITE_SHORTCODE_BASE_URL" = "https://hoppscotch.example.com";
      "VITE_ADMIN_URL" = "https://hoppscotch.example.com/admin";

      "VITE_BACKEND_GQL_URL" = "https://hoppscotch.example.com/backend/graphql";
      "VITE_BACKEND_WS_URL" = "ws://hoppscotch.example.com/backend/graphql";
      "VITE_BACKEND_API_URL" = "https://hoppscotch.example.com/backend/v1";
    };
    ports = [
      "127.0.0.1:3100:80"
    ];
  };
  services.nginx.virtualHosts."hoppscotch.example.com" = {
    forceSSL = true;
    kTLS = true;
    sslCertificate = "/etc/nginx/self-sign.crt";
    sslCertificateKey = "/etc/nginx/self-sign.key";
    extraConfig = ''
      proxy_hide_header X-Powered-By;
      proxy_hide_header Server;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:3100";
      recommendedProxySettings = true;
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
      '';
    };
  };
}
