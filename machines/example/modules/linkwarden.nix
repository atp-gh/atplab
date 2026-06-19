_: {
  services.linkwarden = {
    enable = true;
    database.createLocally = true;
    # enableRegistration = true;
    host = "127.0.0.1";
    port = 3004;
    environmentFile = "/run/secrets/linkwarden";
  };
}
