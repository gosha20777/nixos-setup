# oh-my-pi theme configuration for Everforest Warm.
# Inspired by Tokyo-Night, Titanium, and Taiga.
# Deep, muted, neutral-dark slate backgrounds with a vibrant, fully balanced
# 16-color distribution avoiding any single hue overrepresentation.
let
  inherit ((import ./default.nix)) colors;

  # Taiga/Titanium inspired deep muted neutral-dark backgrounds:
  statusLineBg = "#0F1112"; # Pitch black-slate dock
  userMessageBg = "#1A1D1E"; # Deep subtle slate card
  customMessageBg = "#17191A"; # Very muted neutral-dark slate (no green tint)
  toolPendingBg = "#111314"; # Deepest shadow
  toolSuccessBg = "#131A15"; # Hint of green shadow
  toolErrorBg = "#1C1314"; # Hint of red shadow
  selectedBg = "#23282A"; # Muted neutral selection

  # Quiet structural borders
  border = "#2A2F32";
  borderMuted = "#1D2123";
  statusLineSep = "#2A2F32";

  grey1 = "#8B938D"; # wolf gray
  grey2 = "#828C85"; # smoke gray
in
{
  name = "everforest-warm";
  colors = {
    # Main accent: Frost Teal (cool, elegant, like Titanium)
    accent = colors.c4;
    inherit border;
    borderAccent = colors.c12; # Sky blue focus
    inherit borderMuted;

    success = colors.c2; # Sage green
    error = colors.c1; # Coral red
    warning = colors.c3; # Amber yellow
    muted = grey1;
    dim = grey2;
    text = "";
    thinkingText = grey1;

    inherit selectedBg;
    inherit userMessageBg;
    userMessageText = colors.c15; # Bright white
    inherit customMessageBg;
    customMessageText = colors.fg; # Cream
    customMessageLabel = colors.c5; # Orchid Magenta badge

    inherit toolPendingBg;
    inherit toolSuccessBg;
    inherit toolErrorBg;
    toolTitle = colors.c3; # Amber yellow
    toolOutput = grey1;

    # Markdown elements: Tokyo-Night inspired vibrant hierarchy
    mdHeading = colors.c2; # Sage Green
    mdLink = colors.c12; # Sky Blue
    mdLinkUrl = grey2;
    mdCode = colors.c13; # Rose Pink (excellent contrast and highly readable for inline code)
    mdCodeBlock = colors.fg;
    mdCodeBlockBorder = border;
    mdQuote = grey1;
    mdQuoteBorder = colors.c4; # Frost Teal
    mdHr = statusLineSep;
    mdListBullet = colors.c1; # Coral Red (adds red to markdown!)

    # Diffs
    toolDiffAdded = colors.c10; # Lime green
    toolDiffRemoved = colors.c1; # Coral red
    toolDiffContext = grey2;

    # Syntax in code snippets: Fully distributed semantic colors
    syntaxComment = grey2; # Smoke gray
    syntaxKeyword = colors.c5; # Orchid Magenta keywords
    syntaxFunction = colors.c12; # Sky Blue functions
    syntaxVariable = colors.fg; # Cream variables
    syntaxString = colors.c2; # Sage green strings
    syntaxNumber = colors.c9; # Apricot Orange numbers
    syntaxType = colors.c3; # Amber Yellow types
    syntaxOperator = colors.c1; # Coral Red operators (adds red to code!)
    syntaxPunctuation = grey2;

    # Thinking stages: Cool -> Warm -> Hot progression
    thinkingOff = colors.c0;
    thinkingMinimal = grey2;
    thinkingLow = colors.c4; # Frost Teal
    thinkingMedium = colors.c6; # Aqua Mint
    thinkingHigh = colors.c3; # Amber Yellow
    thinkingXhigh = colors.c9; # Apricot Orange
    thinkingMax = colors.c1; # Coral Red

    bashMode = colors.c6; # Aqua mint
    pythonMode = colors.c11; # Bright Amber

    inherit statusLineBg;
    inherit statusLineSep;

    # Status bar elements: Distinct, balanced tokens
    statusLineModel = colors.c5; # Orchid Magenta
    statusLinePath = colors.c12; # Sky Blue
    statusLineGitClean = colors.c2; # Sage green
    statusLineGitDirty = colors.c3; # Amber yellow
    statusLineContext = colors.c14; # Bright Mint
    statusLineSpend = colors.c11; # Bright Amber
    statusLineStaged = colors.c10; # Lime
    statusLineDirty = colors.c3; # Amber yellow
    statusLineUntracked = colors.c1; # Coral Red
    statusLineOutput = colors.fg; # Cream
    statusLineCost = colors.c9; # Apricot orange
    statusLineSubagents = colors.c4; # Frost Teal
  };
  export = {
    pageBg = colors.bg;
    cardBg = customMessageBg;
    infoBg = userMessageBg;
  };
}
