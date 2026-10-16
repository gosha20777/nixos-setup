{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.services.ollama;
in
{
  options.my.services.ollama = {
    enable = lib.mkEnableOption "Ollama LLM server with CUDA acceleration and Nginx reverse proxy";
    tailscaleFunnel = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Provision Tailscale node identity, TLS certs, and Funnel for p085info013019.tailafc355.ts.net -> 127.0.0.1:11436";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "p085info013019";
        description = "Tailscale node hostname to preserve the Funnel domain across OS installs.";
      };
      domain = lib.mkOption {
        type = lib.types.str;
        default = "p085info013019.tailafc355.ts.net";
        description = "Full Tailscale Funnel FQDN.";
      };
      sopsFile = lib.mkOption {
        type = lib.types.path;
        default = ../../../secrets/tailscale-lab.yaml;
        description = "SOPS file containing encrypted tailscale.state and TLS certs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.ollama_api_key = {
      sopsFile = ../../../secrets/common.yaml;
    };

    sops.secrets."tailscale/state" = lib.mkIf cfg.tailscaleFunnel.enable {
      sopsFile = cfg.tailscaleFunnel.sopsFile;
      mode = "0600";
    };
    sops.secrets."tailscale/acme_key" = lib.mkIf cfg.tailscaleFunnel.enable {
      sopsFile = cfg.tailscaleFunnel.sopsFile;
      mode = "0600";
    };
    sops.secrets."tailscale/cert_crt" = lib.mkIf cfg.tailscaleFunnel.enable {
      sopsFile = cfg.tailscaleFunnel.sopsFile;
      mode = "0644";
    };
    sops.secrets."tailscale/cert_key" = lib.mkIf cfg.tailscaleFunnel.enable {
      sopsFile = cfg.tailscaleFunnel.sopsFile;
      mode = "0600";
    };

    sops.templates."nginx-ollama-auth.conf" = {
      owner = config.services.nginx.user;
      group = config.services.nginx.group;
      mode = "0400";
      content = ''
        if ($http_authorization != "Bearer ${config.sops.placeholder.ollama_api_key}") {
          return 401 '{"error": "Unauthorized: invalid or missing API key"}\n';
        }
      '';
    };

    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      host = "127.0.0.1";
      port = 11434;
      environmentVariables = {
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q4_0";
      };
    };

    networking.firewall.trustedInterfaces = [
      "docker0"
      "tailscale0"
    ];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        # Internal reverse proxy for Julia Hermes Agent (hermes-net bridge container)
        "ollama-julia" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 11435;
            }
          ];
          locations."/" = {
            proxyPass = "http://127.0.0.1:11434";
            extraConfig = ''
              if ($http_authorization != "Bearer ollama") {
                return 401;
              }
              proxy_buffering off;
              proxy_read_timeout 300s;
              proxy_connect_timeout 300s;
              proxy_send_timeout 300s;
            '';
          };
        };

        # External isolated reverse proxy for Tailscale Funnel
        "ollama-tailscale" = {
          listen = [
            {
              addr = "127.0.0.1";
              port = 11436;
            }
          ];
          locations."/" = {
            proxyPass = "http://127.0.0.1:11434";
            extraConfig = ''
              client_max_body_size 64M;
              include ${config.sops.templates."nginx-ollama-auth.conf".path};
              proxy_buffering off;
              proxy_cache off;
              proxy_http_version 1.1;
              proxy_set_header Connection "";
              proxy_read_timeout 600s;
              proxy_connect_timeout 600s;
              proxy_send_timeout 600s;
            '';
          };
        };
      };
    };

    services.tailscale.enable = lib.mkIf cfg.tailscaleFunnel.enable true;

    # Seed /var/lib/tailscale/tailscaled.state and TLS certs from SOPS before
    # tailscaled starts, preserving node IP 100.65.45.32 and Funnel URL
    # https://p085info013019.tailafc355.ts.net without re-authentication.
    systemd.services.tailscaled = lib.mkIf cfg.tailscaleFunnel.enable {
      preStart = lib.mkBefore ''
        install -d -m 0700 /var/lib/tailscale /var/lib/tailscale/certs
        if [ ! -s /var/lib/tailscale/tailscaled.state ] && [ -f ${
          config.sops.secrets."tailscale/state".path
        } ]; then
          install -m 0600 ${config.sops.secrets."tailscale/state".path} /var/lib/tailscale/tailscaled.state
        fi
        if [ ! -s /var/lib/tailscale/certs/acme-account.key.pem ] && [ -f ${
          config.sops.secrets."tailscale/acme_key".path
        } ]; then
          install -m 0600 ${
            config.sops.secrets."tailscale/acme_key".path
          } /var/lib/tailscale/certs/acme-account.key.pem
        fi
        if [ ! -s /var/lib/tailscale/certs/${cfg.tailscaleFunnel.domain}.crt ] && [ -f ${
          config.sops.secrets."tailscale/cert_crt".path
        } ]; then
          install -m 0644 ${
            config.sops.secrets."tailscale/cert_crt".path
          } /var/lib/tailscale/certs/${cfg.tailscaleFunnel.domain}.crt
        fi
        if [ ! -s /var/lib/tailscale/certs/${cfg.tailscaleFunnel.domain}.key ] && [ -f ${
          config.sops.secrets."tailscale/cert_key".path
        } ]; then
          install -m 0600 ${
            config.sops.secrets."tailscale/cert_key".path
          } /var/lib/tailscale/certs/${cfg.tailscaleFunnel.domain}.key
        fi
      '';
    };

    # Enforce Tailscale hostname "p085info013019" (even though NixOS hostName is "lab")
    # and ensure Funnel -> http://127.0.0.1:11436 is active on boot.
    systemd.services.tailscale-funnel-ollama = lib.mkIf cfg.tailscaleFunnel.enable {
      description = "Ensure Tailscale hostname ${cfg.tailscaleFunnel.hostname} and Funnel to 127.0.0.1:11436";
      after = [
        "tailscaled.service"
        "nginx.service"
        "network-online.target"
      ];
      wants = [
        "tailscaled.service"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        for i in $(seq 1 30); do
          if ${config.services.tailscale.package}/bin/tailscale status >/dev/null 2>&1; then
            break
          fi
          sleep 1
        done
        ${config.services.tailscale.package}/bin/tailscale set --hostname=${lib.escapeShellArg cfg.tailscaleFunnel.hostname} || true
        ${config.services.tailscale.package}/bin/tailscale funnel --bg http://127.0.0.1:11436 || true
      '';
    };
  };
}
