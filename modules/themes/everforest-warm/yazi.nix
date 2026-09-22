# Yazi theme configuration for Everforest Warm Refined.
# Generated natively as Nix attrset, rendered to ~/.config/yazi/theme.toml by Home Manager.
let
  inherit ((import ./default.nix)) colors;
in
{
  mgr = {
    cwd = { fg = colors.c4; };
    find_keyword = {
      fg = colors.c3;
      bold = true;
      italic = true;
      underline = true;
    };
    find_position = {
      fg = colors.c5;
      bg = "reset";
      bold = true;
      italic = true;
    };
    marker_copied = { fg = colors.c2; bg = colors.c2; };
    marker_cut = { fg = colors.c1; bg = colors.c1; };
    marker_marked = { fg = colors.c4; bg = colors.c4; };
    marker_selected = { fg = colors.c3; bg = colors.c3; };
    count_copied = { fg = colors.bg; bg = colors.c2; };
    count_cut = { fg = colors.bg; bg = colors.c1; };
    count_selected = { fg = colors.bg; bg = colors.c3; };
    border_symbol = "│";
    border_style = { fg = colors.surfaceDark; };
  };

  tabs = {
    active = { fg = colors.bg; bg = colors.c2; bold = true; };
    inactive = { fg = "#8B938D"; bg = "#1C2022"; };
  };

  mode = {
    normal_main = { fg = colors.bg; bg = colors.c2; bold = true; };
    normal_alt = { fg = colors.c4; bg = colors.surfaceDark; bold = true; };
    select_main = { fg = "#1C2022"; bg = colors.c1; bold = true; };
    select_alt = { fg = colors.c4; bg = colors.surfaceDark; bold = true; };
    unset_main = { fg = "#1C2022"; bg = colors.c4; bold = true; };
    unset_alt = { fg = colors.c4; bg = colors.surfaceDark; bold = true; };
  };

  status = {
    perm_sep = { fg = colors.c0; };
    perm_type = { fg = colors.c2; };
    perm_read = { fg = colors.c3; };
    perm_write = { fg = colors.c1; };
    perm_exec = { fg = colors.c4; };
    progress_label = { bold = true; };
    progress_normal = { fg = colors.c4; bg = "#101112"; };
    progress_error = { fg = colors.c1; bg = "#101112"; };
  };

  pick = {
    border = { fg = colors.c4; };
    active = { fg = colors.c5; bold = true; };
    inactive = { };
  };

  input = {
    border = { fg = colors.c4; };
    title = { };
    value = { };
    selected = { reversed = true; };
  };

  cmp = {
    border = { fg = colors.c4; };
  };

  tasks = {
    border = { fg = colors.c4; };
    title = { };
    hovered = { fg = colors.c5; underline = true; };
  };

  which = {
    mask = { bg = colors.c0; };
    cand = { fg = colors.c4; };
    rest = { fg = colors.c0; };
    desc = { fg = colors.c5; };
    separator = "  ";
    separator_style = { fg = colors.c0; };
  };

  help = {
    on = { fg = colors.c4; };
    run = { fg = colors.c5; };
    hovered = { reversed = true; bold = true; };
    footer = { fg = colors.c0; bg = colors.fg; };
  };

  spot = {
    border = { fg = colors.c4; };
    title = { fg = colors.c4; };
    tbl_col = { fg = colors.c4; };
    tbl_cell = { fg = colors.c3; reversed = true; };
  };

  notify = {
    title_info = { fg = colors.c2; };
    title_warn = { fg = colors.c3; };
    title_error = { fg = colors.c1; };
  };

  filetype = {
    rules = [
      { mime = "image/*"; fg = colors.c4; }
      { mime = "{audio,video}/*"; fg = colors.c5; }
      { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; fg = colors.c1; }
      { mime = "application/{pdf,doc,rtf}"; fg = colors.c4; }
      { mime = "vfs/{absent,stale}"; fg = colors.surfaceDark; }
      { url = "*"; fg = colors.c6; }
      { url = "*/"; fg = colors.c2; }
    ];
  };
}
