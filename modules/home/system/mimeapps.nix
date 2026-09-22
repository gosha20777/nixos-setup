# Default browser. Signal's Electron shell rewrites ~/.config/mimeapps.list
# on first launch when no default is set, hijacking http/https/text/html
# for itself — so `xdg-open https://...` (e.g. `gh auth refresh`) opens
# Signal instead of a browser. home-manager replaces mimeapps.list with a
# store-path symlink, which Signal can't clobber.
{
  ...
}:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "chromium-browser.desktop";
      "x-scheme-handler/http" = "chromium-browser.desktop";
      "x-scheme-handler/https" = "chromium-browser.desktop";
      "x-scheme-handler/about" = "chromium-browser.desktop";
      "x-scheme-handler/unknown" = "chromium-browser.desktop";
      # Claude Code's URL handler (claude-cli://...) — preserved from the
      # runtime mimeapps.list so `claude` URL launches still work.
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      "inode/directory" = "nemo.desktop";
    };
  };
}
