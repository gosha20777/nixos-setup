# yazi — fast terminal file manager in Rust (image previews in kitty).
{
  pkgs,
  systemSettings,
  ...
}:
let
  theme = import ../../themes/${systemSettings.theme};
in
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true; # `y` function in fish (cd on quit)
    theme = theme.yazi;

    plugins = {
      smart-enter = pkgs.yaziPlugins.smart-enter;
    };

    settings = {
      opener = {
        edit = [
          {
            run = "nvim \"$@\"";
            block = true;
            desc = "Neovim";
          }
          {
            run = "code \"$@\"";
            orphan = true;
            desc = "VS Code";
          }
        ];
        image = [
          {
            run = "vipsdisp \"$@\"";
            orphan = true;
            desc = "vipsdisp";
          }
          {
            run = "gthumb \"$@\"";
            orphan = true;
            desc = "gThumb";
          }
          {
            run = "ART \"$@\"";
            orphan = true;
            desc = "ART";
          }
        ];
        folder = [
          {
            run = "gthumb \"$@\"";
            orphan = true;
            desc = "gThumb";
          }
          {
            run = "nemo \"$@\"";
            orphan = true;
            desc = "Nemo";
          }
          {
            run = "code \"$@\"";
            orphan = true;
            desc = "VS Code";
          }
        ];
      };

      open = {
        prepend_rules = [
          {
            mime = "image/*";
            use = [
              "image"
              "reveal"
            ];
          }
          {
            url = "*.{tif,tiff,dng,cr2,cr3,nef,arw,raf,orf,pef,rw2,raw}";
            use = [
              "image"
              "reveal"
            ];
          }
          {
            mime = "text/*";
            use = [
              "edit"
              "reveal"
            ];
          }
          {
            mime = "folder/*";
            use = [
              "folder"
              "reveal"
            ];
          }
        ];
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "<Enter>";
          run = "plugin smart-enter";
          desc = "Enter directory or open file";
        }
        {
          on = "a";
          run = "create";
          desc = "Create a file";
        }
        {
          on = "A";
          run = "create --dir";
          desc = "Create a directory";
        }
      ];
    };
  };
}
