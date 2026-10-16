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
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.ollama_api_key = {
      sopsFile = ../../../secrets/common.yaml;
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
  };
}
