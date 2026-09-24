# oh-my-pi theme configuration for Everforest Warm.
# Conforms to oh-my-pi theme schema and .agents/skills/everforest-warm/SKILL.md.
let
  inherit ((import ./default.nix)) colors;
  # Elevated structural surfaces & visible borders for TUI clarity
  border = "#3C4A44"; # crisp forest slate (CR 1.95:1 to #141617)
  borderMuted = "#303D37"; # subtle inner border
  statusLineBg = "#1E2724"; # grounded forest dock
  userMessageBg = "#262C30"; # warm slate card
  customMessageBg = "#202E27"; # rich forest model card
  toolPendingBg = "#1E2C2E"; # deep teal charcoal
  toolSuccessBg = "#1D2E24"; # deep forest moss
  toolErrorBg = "#332024"; # deep wine coral
  selectedBg = "#2C3C40"; # selection_background из kitty.conf
  grey1 = "#8B938D";
  grey2 = "#A5ADA7";
  mdHr = "#374246";
in
{
  name = "everforest-warm";
  colors = {
    accent = colors.accent;
    inherit border;
    borderAccent = colors.c10;
    inherit borderMuted;
    success = colors.accent;
    error = colors.coral;
    warning = colors.apricot;
    muted = grey1;
    dim = colors.smoke;
    text = colors.fg;
    thinkingText = grey1;

    inherit selectedBg;
    inherit userMessageBg;
    userMessageText = colors.c15;
    inherit customMessageBg;
    customMessageText = colors.fg;
    customMessageLabel = colors.c14;
    inherit toolPendingBg;
    inherit toolSuccessBg;
    inherit toolErrorBg;
    toolTitle = colors.accent2;
    toolOutput = grey2;

    mdHeading = colors.c10;
    mdLink = colors.c12;
    mdLinkUrl = grey1;
    mdCode = colors.c11;
    mdCodeBlock = colors.fg;
    mdCodeBlockBorder = border;
    mdQuote = colors.fg;
    mdQuoteBorder = colors.gold;
    inherit mdHr;
    mdListBullet = colors.apricot;

    toolDiffAdded = colors.c10;
    toolDiffRemoved = colors.coral;
    toolDiffContext = colors.smoke;

    syntaxComment = grey1;
    syntaxKeyword = colors.coral;
    syntaxFunction = colors.accent;
    syntaxVariable = colors.fg;
    syntaxString = colors.gold;
    syntaxNumber = colors.c5;
    syntaxType = colors.accent2;
    syntaxOperator = colors.apricot;
    syntaxPunctuation = grey2;

    thinkingOff = colors.c0; # color0 из kitty.conf (#262B2E)
    thinkingMinimal = colors.smoke; # color8 из kitty.conf (#828C85)
    thinkingLow = colors.accent2; # color4 из kitty.conf (#65B8C7)
    thinkingMedium = colors.c6; # color6 из kitty.conf (#52BFA3)
    thinkingHigh = colors.accent; # color2 из kitty.conf (#9EC468)
    thinkingXhigh = colors.gold; # color3 из kitty.conf (#E2B862)
    thinkingMax = colors.apricot; # color9 из kitty.conf (#F2874B)

    bashMode = colors.c14; # color14 из kitty.conf (#69D3B7)
    pythonMode = colors.c13; # color13 из kitty.conf (#E592B1)

    inherit statusLineBg;
    statusLineSep = colors.surfaceDark; # inactive_border_color из kitty.conf (#282D30)
    statusLineModel = colors.c13;
    statusLinePath = colors.c12;
    statusLineGitClean = colors.accent;
    statusLineGitDirty = colors.apricot;
    statusLineContext = colors.c14;
    statusLineSpend = colors.c11;
    statusLineStaged = colors.c10;
    statusLineDirty = colors.gold;
    statusLineUntracked = colors.coral;
    statusLineOutput = colors.fg;
    statusLineCost = colors.apricot;
    statusLineSubagents = colors.c5;
  };
  export = {
    pageBg = colors.bg;
    cardBg = customMessageBg;
    infoBg = userMessageBg;
  };
}
