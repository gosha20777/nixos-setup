# VS Code theme configuration for Everforest Warm (based on classic VS Code Dark+).
# Blue is turned to warm green (sage), background to warm dark canvas (#141617),
# and selection is calm forest green preserving text colors and readability.
let
  accent = "#9EC468"; # Warm sage green (replaces VS Code blue #569cd6)
  accentBright = "#AFD874"; # Bright warm lime/sage (self, cls, active highlights)
  bgCanvas = "#141617"; # Deep warm dark editor background
  bgSurface = "#181B1C"; # Grounded surface (sidebar, status, tabs, title)
  bgInput = "#1E2325"; # Elevated input surface
  borderSubtle = "#222729"; # Subtle border
  borderMuted = "#303937"; # Input/divider border
  fgMain = "#E1DACB"; # Warm readable text
  fgMuted = "#8B938D"; # Secondary/inactive text

  # Calm forest green selection: non-glaring, preserves syntax colors (CR > 4:1)
  selectionBg = "#2D4236";
  selectionInactive = "#202E27";
in
{
  colorCustomizations = {
    # Editor background & cursor
    "editor.background" = bgCanvas;
    "editor.foreground" = fgMain;
    "editorLineNumber.foreground" = "#505A60";
    "editorLineNumber.activeForeground" = accentBright;
    "editorCursor.foreground" = fgMain;

    # Calm, non-glaring green selection without text color clobbering
    "editor.selectionBackground" = selectionBg;
    "editor.inactiveSelectionBackground" = selectionInactive;
    "editor.selectionHighlightBackground" = "${accent}22";
    "editor.wordHighlightBackground" = "${accent}24";
    "editor.wordHighlightStrongBackground" = "${accent}35";
    "editor.findMatchBackground" = "#F2874B55";
    "editor.findMatchHighlightBackground" = "#E2B86233";

    # UI Chrome (Sidebar, ActivityBar, TitleBar, Tabs, StatusBar)
    "activityBar.background" = bgCanvas;
    "activityBar.foreground" = fgMain;
    "activityBar.inactiveForeground" = fgMuted;
    "activityBar.border" = borderSubtle;
    "activityBarBadge.background" = accent;
    "activityBarBadge.foreground" = bgCanvas;

    "sideBar.background" = bgSurface;
    "sideBar.foreground" = "#D4D4D4";
    "sideBar.border" = borderSubtle;
    "sideBarTitle.foreground" = fgMain;
    "sideBarSectionHeader.background" = bgSurface;
    "sideBarSectionHeader.foreground" = fgMain;

    "editorGroupHeader.tabsBackground" = bgSurface;
    "editorGroupHeader.tabsBorder" = borderSubtle;
    "tab.activeBackground" = bgCanvas;
    "tab.activeForeground" = fgMain;
    "tab.activeBorderTop" = accent;
    "tab.inactiveBackground" = bgSurface;
    "tab.inactiveForeground" = fgMuted;
    "tab.border" = borderSubtle;

    "titleBar.activeBackground" = bgCanvas;
    "titleBar.activeForeground" = fgMain;
    "titleBar.inactiveBackground" = bgCanvas;
    "titleBar.inactiveForeground" = fgMuted;
    "titleBar.border" = borderSubtle;

    "statusBar.background" = bgSurface;
    "statusBar.foreground" = "#D4D4D4";
    "statusBar.border" = borderSubtle;
    "statusBar.debuggingBackground" = selectionBg;
    "statusBar.noFolderBackground" = bgSurface;
    "statusBarItem.remoteBackground" = accent;
    "statusBarItem.remoteForeground" = bgCanvas;

    # Interactive elements: Focus, Buttons, Inputs, Lists
    "focusBorder" = accent;
    "button.background" = accent;
    "button.foreground" = bgCanvas;
    "button.hoverBackground" = accentBright;

    "input.background" = bgInput;
    "input.foreground" = fgMain;
    "input.border" = borderMuted;
    "inputOption.activeBorder" = accent;

    "list.activeSelectionBackground" = "#2A3A32";
    "list.activeSelectionForeground" = "#F7F4EC";
    "list.inactiveSelectionBackground" = "#202B25";
    "list.hoverBackground" = "#1C2422";
    "list.focusHighlightForeground" = accent;
    "list.highlightForeground" = accent;

    "menu.background" = bgInput;
    "menu.foreground" = fgMain;
    "menu.selectionBackground" = "#2A3A32";
    "menu.selectionForeground" = "#F7F4EC";
    "menu.separatorBackground" = borderMuted;

    "terminal.background" = bgCanvas;
    "terminal.foreground" = fgMain;
    "terminal.selectionBackground" = selectionBg;

    "tree.indentGuidesStroke" = borderMuted;
    "editorIndentGuide.background1" = "#283032";
    "editorIndentGuide.activeBackground1" = "#4A5856";
  };

  # Syntax token customization: Blue -> Warm Green (Sage)
  tokenColorCustomizations = {
    "comments" = "#7A8A7E";
    "keywords" = accent;
    "numbers" = "#B5CEA8";
    "strings" = "#CE9178";
    "types" = "#4EC9B0";
    "functions" = "#DCDCAA";
    "textMateRules" = [
      # Keywords, storage, language constants, logical operators (Blue -> Sage Green)
      {
        "scope" = [
          "keyword"
          "storage"
          "storage.type"
          "storage.modifier"
          "keyword.operator.logical.python"
          "constant.language"
          "entity.name.tag"
          "meta.preprocessor"
        ];
        "settings" = {
          "foreground" = accent;
        };
      }
      # Python self and cls: bright distinct lime/sage
      {
        "scope" = [
          "variable.language"
          "variable.language.special.self.python"
          "variable.language.special.cls.python"
        ];
        "settings" = {
          "foreground" = accentBright;
        };
      }
      # Control flow keywords (if, else, return, for, while, try, except, with)
      {
        "scope" = [
          "keyword.control"
        ];
        "settings" = {
          "foreground" = "#C586C0";
        };
      }
      # Function declarations, calls and decorators (Dark+ warm golden khaki)
      {
        "scope" = [
          "entity.name.function"
          "support.function"
          "entity.name.function.decorator.python"
        ];
        "settings" = {
          "foreground" = "#DCDCAA";
        };
      }
      # Types and classes (Dark+ soft aqua-sage)
      {
        "scope" = [
          "support.class"
          "support.type"
          "entity.name.type"
          "entity.name.class"
        ];
        "settings" = {
          "foreground" = "#4EC9B0";
        };
      }
    ];
  };

  # Clean semantic token customizations for Python LSP
  semanticTokenColorCustomizations = {
    "rules" = {
      "selfKeyword" = accentBright;
      "clsKeyword" = accentBright;
    };
  };
}
