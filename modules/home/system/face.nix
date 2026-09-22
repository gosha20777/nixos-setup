# Аватар: ~/.face (greeter/accountsservice) + ~/Pictures/Avatars/me.jpg
# (shell.avatar_path Noctalia, стикер локскрина). Store-symlink'и —
# файлы фиксированные, заменяются правкой ассета в git.
{
  home.file = {
    ".face".source = ../../../assets/avatars/me.jpg;
    "Pictures/Avatars/me.jpg".source = ../../../assets/avatars/me.jpg;
  };
}
