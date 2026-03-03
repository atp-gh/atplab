_: let
  # Set it and don't change.Knot would
  dnsSerial = "2026030201";
in {
  services.knot = {
    enable = true;
    settings = {
      server = {
        listen = [
          "172.20.192.3@53"
          "fd25:5547:5a89::3@53"
        ];
      };
      policy = [
        {
          id = "dn42-dnssec";
          algorithm = "ed25519";
          ksk-lifetime = "3650d";
          zsk-lifetime = "30d";
          dnskey-ttl = "1h";
          rrsig-lifetime = "14d";
          nsec3 = false;
        }
      ];
      template = [
        {
          id = "dn42";
          storage = "/etc/knot/dn42";
          dnssec-signing = true;
          dnssec-policy = "dn42-dnssec";
        }
      ];
      zone = [
        {
          domain = "atp.dn42";
          file = "atp.dn42.zone";
          template = "dn42";
        }
        {
          domain = "0/28.192.20.172.in-addr.arpa";
          file = "dn42.v4.rev.zone";
          template = "dn42";
        }
        {
          domain = "9.8.a.5.7.4.5.5.5.2.d.f.ip6.arpa";
          file = "dn42.v6.rev.zone";
          template = "dn42";
        }
      ];
    };
  };
  environment.etc = {
    "knot/dn42/atp.dn42.zone" = {
      user = "knot";
      group = "knot";
      mode = "0400";
      text = ''
        $ORIGIN atp.dn42.
        $TTL 1h

        @   IN SOA ns1.atp.dn42. hostmaster.atp.dn42. (
                ${dnsSerial} ; serial
                1h         ; refresh
                15m        ; retry
                30d        ; expire
                2h         ; minimum
        )

            IN NS  ns1.atp.dn42.

        ns1 IN A     172.20.192.3
        ns1 IN AAAA  fd25:5547:5a89::3

        ; Custom dns
        octopus IN A 172.20.192.1
        octopus IN AAAA fd25:5547:5a89::1
        squid IN A 172.20.192.2
        squid IN AAAA fd25:5547:5a89::2
        cthulhu IN A 172.20.192.3
        cthulhu IN AAAA fd25:5547:5a89::3
        test IN  A 172.20.192.3
      '';
    };
    "knot/dn42/dn42.v4.rev.zone" = {
      user = "knot";
      group = "knot";
      mode = "0400";
      text = ''
        $ORIGIN 0/28.192.20.172.in-addr.arpa.
        $TTL 1h

        @ IN SOA ns1.atp.dn42. hostmaster.atp.dn42. (
            ${dnsSerial}
            1h
            15m
            30d
            2h
        )

            IN NS ns1.atp.dn42.

        3   IN PTR ns1.atp.dn42.
      '';
    };
    "knot/dn42/dn42.v6.rev.zone" = {
      user = "knot";
      group = "knot";
      mode = "0400";
      text = ''
        $ORIGIN 9.8.a.5.7.4.5.5.5.2.d.f.ip6.arpa.
        $TTL 1h

        @ IN SOA ns1.atp.dn42. hostmaster.atp.dn42. (
            ${dnsSerial}
            1h
            15m
            30d
            2h
        )

            IN NS ns1.atp.dn42.

        ; fd25:5547:5a89::3
        3.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 IN PTR ns1.atp.dn42.
      '';
    };
  };
  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
