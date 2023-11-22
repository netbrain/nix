{ pkgs, config, ... }:
{
  
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    networkmanager-sstp
    networkmanager-openvpn
  ];

  sops.secrets = {
    "davo/vpn/password" = {};
    "lyse/wifi/lyse-byod/password" = {};
    "lyse/vpn/ca" = {};
    "lyse/vpn/cert" = {};
    "lyse/vpn/key" = {};
    "lyse/vpn/tls-crypt" = {};
    "home/wifi/netwifi/password" = {};
  };

  sops.templates."networkmanager".content = ''

    LYSE_VPN_CA = "${config.sops.secrets."lyse/vpn/ca".path}"
    LYSE_VPN_CERT = "${config.sops.secrets."lyse/vpn/cert".path}"
    LYSE_VPN_KEY = "${config.sops.secrets."lyse/vpn/key".path}"
    LYSE_VPN_TLS_CRYPT = "${config.sops.secrets."lyse/vpn/tls-crypt".path}"
    LYSE_WIFI_LYSE_BYOD_PASSWORD = "${config.sops.placeholder."lyse/wifi/lyse-byod/password"}"
    DAVO_VPN_PASSWORD = "${config.sops.placeholder."davo/vpn/password"}"
    HOME_WIFI_NETWIFI_PASSWORD = "${config.sops.placeholder."home/wifi/netwifi/password"}"
  '';

  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [ /run/secrets-rendered/networkmanager ];
      profiles = {
        lyse-byod = {
          connection = {
            id = "Lyse BYOD";
            uuid = "4c9fdd66-e276-479f-86c4-98abb24c1541";
            type = "wifi";
            interface-name = "wlp0s20f3";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "Lyse BYOD";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$LYSE_WIFI_LYSE_BYOD_PASSWORD";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
          proxy = {
          };
        };
        lyse-vpn = {
          connection = {
            id = "Lyse";
            uuid = "c6db676b-ac95-49fd-b884-fcb840c4f4df";
            type = "vpn";
            autoconnect = "false";
            timestamp = "1698410176";
          };
          vpn = {
            ca = "$LYSE_VPN_CA";
            cert = "$LYSE_VPN_CERT";
            cert-pass-flags = "0";
            cipher = "AES-256-CBC";
            connect-timeout = "4";
            connection-type = "password-tls";
            dev = "tun";
            dev-type = "tun";
            key = "$LYSE_VPN_KEY";
            password-flags = "1";
            push-peer-info = "yes";
            remote = "gmvpn.altibox.net:1194:udp, gmvpn.altibox.net:1194:udp, gmvpn.altibox.net:1194:tcp, gmvpn.altibox.net:1194:udp, gmvpn.altibox.net:1194:udp, gmvpn.altibox.net:1194:udp, gmvpn.altibox.net:1194:udp, gmvpn.altibox.net:1194:udp";
            remote-cert-tls = "server";
            reneg-seconds = "604800";
            tls-crypt = "$LYSE_VPN_TLS_CRYPT";
            tls-version-min = "1.2";
            tunnel-mtu = "1500";
            username = "kimei";
            service-type = "org.freedesktop.NetworkManager.openvpn";
          };
          ipv4 = {
            method = "auto";
            never-default = "true";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          proxy = {
          };
        };
        davo = {
          connection = {
            id = "Davo";
            uuid = "8dad9690-4105-4512-9f76-27d765ea8b71";
            type = "vpn";
            autoconnect = "false";
            timestamp = "1694410977";
          };
          vpn = {
            connection-type = "password";
            gateway = "vpn.davo.no:1195";
            ignore-cert-warn = "yes";
            password-flags = "0";
            refuse-chap = "no";
            refuse-eap = "yes";
            refuse-mschap = "no";
            refuse-mschapv2 = "no";
            refuse-pap = "yes";
            tls-ext = "yes";
            tls-verify-key-usage = "no";
            unit = "0";
            user = "ke";
            service-type = "org.freedesktop.NetworkManager.sstp";
          };
          vpn-secrets = {
            password = "$DAVO_VPN_PASSWORD";
          };
          ipv4 = {
            dns = "10.0.0.1;";
            ignore-auto-routes = "true";
            method = "auto";
            never-default = "true";
            route1 = "10.0.0.0/8,10.0.0.1";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "disabled";
          };
          proxy = {
          };
        };
        netwifi = {
          connection = {
            id = "netwifi";
            uuid = "c02047a8-5184-461b-acef-c63ba66e891c";
            type = "wifi";
            interface-name = "wlp0s20f3";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "netwifi";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$HOME_WIFI_NETWIFI_PASSWORD";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
          proxy = {
          };
        };
      };
    };
  };
}
