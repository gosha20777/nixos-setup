# Everforest Warm theme for Telegram Desktop (.tdesktop-theme colors.tdesktop)
# Strictly adheres to the canonical Everforest Warm palette.
let
  inherit ((import ./default.nix)) colors;
in
''
  // Everforest Warm — Telegram Desktop Theme
  // Canonical palette: bg=#141617, fg=#E1DACB, sage=#9EC468, pine=#65B8C7

  // Window & Base Elements
  windowBg: ${colors.bg};
  windowFg: ${colors.fg};
  windowBgOver: ${colors.c0};
  windowBgRipple: #2C3C40;
  windowFgOver: ${colors.c15};
  windowSubTextFg: ${colors.smoke};
  windowSubTextFgOver: #8B938D;
  windowBoldFg: ${colors.fg};
  windowBoldFgOver: ${colors.c15};
  windowBgActive: ${colors.accent};
  windowFgActive: ${colors.bg};
  windowActiveTextFg: ${colors.c6};
  windowShadowFg: #101112;
  windowShadowFgFallback: #101112;
  shadowFg: #101112;

  // Buttons
  activeButtonBg: ${colors.accent};
  activeButtonBgOver: ${colors.c10};
  activeButtonBgRipple: #2C3C40;
  activeButtonFg: ${colors.bg};
  activeButtonFgOver: ${colors.bg};
  activeButtonSecondaryFg: ${colors.c0};
  activeButtonSecondaryFgOver: ${colors.c0};
  activeLineFg: ${colors.accent};
  activeLineFgError: ${colors.coral};
  lightButtonBg: ${colors.c0};
  lightButtonBgOver: #2C3C40;
  lightButtonBgRipple: #374246;
  lightButtonFg: ${colors.fg};
  lightButtonFgOver: ${colors.c15};

  // Menus & Context Menus
  menuBg: #1A1D1F;
  menuBgOver: ${colors.c0};
  menuBgRipple: #2C3C40;
  menuIconFg: ${colors.smoke};
  menuIconFgOver: #8B938D;
  menuSubmenuArrowFg: ${colors.smoke};
  menuFgDisabled: #A5ADA7;
  menuSeparatorFg: ${colors.surfaceDark};

  // Titlebar / System Frame
  titleBg: #1A1D1F;
  titleBgActive: #1A1D1F;
  titleTextFg: ${colors.smoke};
  titleTextFgActive: ${colors.fg};
  titleButtonBg: #1A1D1F;
  titleButtonFg: ${colors.smoke};
  titleButtonBgOver: ${colors.c0};
  titleButtonFgOver: ${colors.fg};
  titleButtonCloseBg: #1A1D1F;
  titleButtonCloseFg: ${colors.smoke};
  titleButtonCloseBgOver: ${colors.coral};
  titleButtonCloseFgOver: ${colors.bg};

  // Dialogs List (Sidebar)
  dialogsBg: #1A1D1F;
  dialogsBgOver: ${colors.c0};
  dialogsBgActive: #2C3C40;
  dialogsNameFg: ${colors.fg};
  dialogsNameFgOver: ${colors.c15};
  dialogsNameFgActive: ${colors.c15};
  dialogsChatIconFg: ${colors.accent2};
  dialogsChatIconFgOver: ${colors.accent2};
  dialogsChatIconFgActive: ${colors.accent2};
  dialogsDateFg: ${colors.smoke};
  dialogsDateFgOver: #8B938D;
  dialogsDateFgActive: #A5ADA7;
  dialogsTextFg: ${colors.smoke};
  dialogsTextFgOver: #8B938D;
  dialogsTextFgActive: ${colors.fg};
  dialogsUnreadBg: ${colors.accent};
  dialogsUnreadFg: ${colors.bg};
  dialogsUnreadBgOver: ${colors.c10};
  dialogsUnreadFgOver: ${colors.bg};
  dialogsUnreadBgActive: ${colors.accent};
  dialogsUnreadFgActive: ${colors.bg};
  dialogsUnreadBgMuted: ${colors.smoke};
  dialogsUnreadFgMuted: ${colors.bg};
  dialogsUnreadBgMutedOver: #8B938D;
  dialogsUnreadFgMutedOver: ${colors.bg};
  dialogsUnreadBgMutedActive: ${colors.smoke};
  dialogsUnreadFgMutedActive: ${colors.bg};
  dialogsDraftFg: ${colors.coral};
  dialogsVerifiedIconBg: ${colors.accent};
  dialogsVerifiedIconFg: ${colors.bg};

  // Chat History & Messages
  chatBg: ${colors.bg};
  historyTextInFg: ${colors.fg};
  historyTextOutFg: ${colors.fg};
  historyLinkInFg: ${colors.c6};
  historyLinkOutFg: ${colors.accent};
  historyFileNameInFg: ${colors.fg};
  historyFileNameOutFg: ${colors.fg};
  historyOutIconFg: ${colors.accent};
  historyOutIconFgSelected: ${colors.c10};
  historyInIconFg: ${colors.smoke};
  historyInIconFgSelected: #A5ADA7;

  // Incoming Messages
  msgInBg: #1A1D1F;
  msgInBgSelected: #2C3C40;
  msgInShadow: #10111200;
  msgInDateFg: ${colors.smoke};
  msgInDateFgSelected: #8B938D;
  msgInReplyBarColor: ${colors.c6};
  msgInReplyBarSelColor: ${colors.c14};

  // Outgoing Messages
  msgOutBg: ${colors.c0};
  msgOutBgSelected: #374246;
  msgOutShadow: #10111200;
  msgOutDateFg: #8B938D;
  msgOutDateFgSelected: #A5ADA7;
  msgOutReplyBarColor: ${colors.accent};
  msgOutReplyBarSelColor: ${colors.c10};

  // File Attachments
  msgFileInBg: ${colors.c0};
  msgFileInBgOver: #2C3C40;
  msgFileInBgSelected: #374246;
  msgFileOutBg: #1A1D1F;
  msgFileOutBgOver: ${colors.c0};
  msgFileOutBgSelected: #2C3C40;

  // Input & Compose Area
  historyComposeAreaBg: #1A1D1F;
  historyComposeAreaFg: ${colors.fg};
  historyComposeField: #1A1D1F;
  historyComposeFieldPlaceholder: ${colors.smoke};
  historyComposeIconFg: ${colors.smoke};
  historyComposeIconFgOver: ${colors.accent};
  historySendIconFg: ${colors.accent};
  historySendIconFgOver: ${colors.c10};
  historyPinnedBg: #1A1D1F;
  historyReplyBg: #1A1D1F;
  historyReplyCancelFg: ${colors.smoke};
  historyReplyCancelFgOver: ${colors.coral};

  // Popups & Modal Boxes
  boxBg: ${colors.bg};
  boxTextFg: ${colors.fg};
  boxTextFgGood: ${colors.accent};
  boxTextFgError: ${colors.coral};
  boxTitleFg: ${colors.fg};
  boxSearchBg: #1A1D1F;
  boxSearchPlaceholder: ${colors.smoke};
  boxDividerBg: ${colors.surfaceDark};

  // Scrollbars
  scrollBarBg: #14161700;
  scrollBarBgOver: ${colors.c0};
  scrollBg: #14161700;
  scrollBgOver: ${colors.c0};
''
