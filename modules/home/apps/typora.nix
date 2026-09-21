# Typora theme. Lives at ~/.config/Typora/themes/noctalia.css; Typora reads
# themes but never writes them, so a store-path symlink is fine here (unlike
# the bat/starship configs). Pick it via Themes → Noctalia after a
# rebuild — Typora persists the selection in its profile.data.
#
# UNLIKE every other themed surface in this tree, this one is a STATIC
# SNAPSHOT and will drift. Noctalia has no `typora` template (the catalog at
# api.noctalia.dev/templates has no entry for it), so nothing regenerates
# these values when the wallpaper — and therefore the Material palette —
# changes. The colours were taken from the m3-tonal-spot palette derived
# from the dark-blue wallpaper set as the default.
#
# To re-snapshot after a wallpaper change, read the live values and remap:
#   grep '^@define-color' ~/.config/gtk-3.0/noctalia.css
#   cat ~/.cache/noctalia/starship-palette.toml   # named/Catppuccin slots
# then substitute by ROLE, not by eye — the ladder below is what keeps the
# chrome readable:
#   base    #101418  page background        (starship `base`)
#   surface #1c2024  sidebar, header, footer, code inline
#   hover   #252a30  item hover
#   select  #323539  active file, text selection
#   outline #42474e  borders, rules         (starship `surface2`)
#   muted   #8c9198  meta text, md syntax chars (starship `subtext0`)
#   dim     #c2c7cf  heading chars
#   accent  #9acbfa  primary/links/active border
#   text    #e0e2e8  body copy              (starship `text`)
#   sunken  #0a0e12  code block background (one step under base)
#
# The CSS itself lives in modules/data/typora-noctalia.css.
{ ... }: {
  xdg.configFile."Typora/themes/noctalia.css".source = ../../data/typora-noctalia.css;
}
