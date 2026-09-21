{
  systemSettings,
  ...
}:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = systemSettings.gitUsername;
        email = systemSettings.gitEmail;
      };
      # Delegate GitHub HTTPS auth to gh so git push uses the token gh stores
      # in the system keyring. Declared here because home-manager renders
      # ~/.config/git/config as a read-only store symlink — `gh auth setup-git`
      # can't write into it at runtime.
      credential."https://github.com".helper = "!gh auth git-credential";
      credential."https://gist.github.com".helper = "!gh auth git-credential";
    };
  };
}
