# VS Code theme configuration for Everforest Warm Refined.
# Generated from upstream everforest-dark-vibrant.json adapted to Everforest Warm.
# Conforms to .agents/skills/everforest-warm/SKILL.md.
let
  inherit ((import ./default.nix)) colors;
  bg1 = "#1A1D1F";
  bg4 = "#2C3C40";
  bg5 = "#374246";
  bgDim = "#101112";
in
{
  colorCustomizations = {
    "foreground" = "#a5ada7";
    "focusBorder" = "${colors.bg}00";
    "widget.shadow" = "${bgDim}70";
    "selection.background" = "${colors.selectionBg}";
    "descriptionForeground" = "#8b938d";
    "errorForeground" = "${colors.coral}";
    "icon.foreground" = "${colors.c6}";
    "textLink.foreground" = "${colors.accent}";
    "textLink.activeForeground" = "${colors.accent}c0";
    "textCodeBlock.background" = "${bg1}";
    "textBlockQuote.background" = "${bg1}";
    "textBlockQuote.border" = "${bg4}";
    "textPreformat.foreground" = "${colors.gold}";
    "toolbar.hoverBackground" = "${colors.c0}";
    "button.background" = "${colors.accent}";
    "button.hoverBackground" = "${colors.accent}d0";
    "button.foreground" = "${colors.bg}";
    "button.secondaryBackground" = "${colors.surfaceDark}";
    "button.secondaryForeground" = "${colors.fg}";
    "button.secondaryHoverBackground" = "${bg4}";
    "checkbox.background" = "${colors.bg}";
    "checkbox.foreground" = "${colors.apricot}";
    "checkbox.border" = "${bg5}";
    "dropdown.border" = "${bg5}";
    "dropdown.background" = "${colors.bg}";
    "dropdown.foreground" = "#a5ada7";
    "input.border" = "${bg5}";
    "input.background" = "${colors.bg}00";
    "input.foreground" = "${colors.fg}";
    "input.placeholderForeground" = "${colors.smoke}";
    "inputOption.activeBorder" = "${colors.c6}";
    "inputValidation.errorBorder" = "${colors.coral}";
    "inputValidation.errorBackground" = "#b84e54";
    "inputValidation.errorForeground" = "${colors.fg}";
    "inputValidation.infoBorder" = "${colors.accent2}";
    "inputValidation.infoBackground" = "#45818d";
    "inputValidation.infoForeground" = "${colors.fg}";
    "inputValidation.warningBorder" = "${colors.gold}";
    "inputValidation.warningBackground" = "#a8843e";
    "inputValidation.warningForeground" = "${colors.fg}";
    "scrollbar.shadow" = "${bgDim}70";
    "scrollbarSlider.activeBackground" = "#a5ada7";
    "scrollbarSlider.hoverBackground" = "${bg5}";
    "scrollbarSlider.background" = "${bg5}80";
    "badge.background" = "${colors.accent}";
    "badge.foreground" = "${colors.bg}";
    "progressBar.background" = "${colors.accent}";
    "list.activeSelectionForeground" = "${colors.fg}";
    "list.activeSelectionBackground" = "${bg4}a0";
    "list.inactiveSelectionForeground" = "#a5ada7";
    "list.inactiveSelectionBackground" = "${bg4}80";
    "list.dropBackground" = "${colors.c0}80";
    "list.focusForeground" = "${colors.fg}";
    "list.focusBackground" = "${bg4}a0";
    "list.inactiveFocusBackground" = "${bg4}60";
    "list.highlightForeground" = "${colors.accent}";
    "list.hoverForeground" = "${colors.fg}";
    "list.hoverBackground" = "${colors.bg}00";
    "list.invalidItemForeground" = "#b84e54";
    "list.errorForeground" = "${colors.coral}";
    "list.warningForeground" = "${colors.gold}";
    "tree.indentGuidesStroke" = "${colors.smoke}";
    "activityBar.border" = "${colors.bg}";
    "activityBar.background" = "${colors.bg}";
    "activityBar.foreground" = "${colors.fg}";
    "activityBar.inactiveForeground" = "#8b938d";
    "activityBar.dropBackground" = "${colors.bg}";
    "activityBar.activeBorder" = "${colors.accent}d0";
    "activityBar.activeFocusBorder" = "${colors.accent}";
    "activityBarBadge.background" = "${colors.accent}";
    "activityBarBadge.foreground" = "${colors.bg}";
    "sideBar.foreground" = "#8b938d";
    "sideBar.background" = "${colors.bg}";
    "sideBarSectionHeader.background" = "${colors.bg}00";
    "sideBarTitle.foreground" = "#a5ada7";
    "sideBarSectionHeader.foreground" = "#a5ada7";
    "minimap.findMatchHighlight" = "#38877260";
    "minimap.selectionHighlight" = "${bg5}f0";
    "minimap.errorHighlight" = "#b84e5480";
    "minimap.warningHighlight" = "#a8843e80";
    "minimapGutter.addedBackground" = "#6d8c43a0";
    "minimapGutter.modifiedBackground" = "#45818da0";
    "minimapGutter.deletedBackground" = "#b84e54a0";
    "editorGroup.border" = "${bg1}";
    "editorGroupHeader.tabsBackground" = "${colors.bg}";
    "editorGroupHeader.noTabsBackground" = "${colors.bg}";
    "editorGroup.dropBackground" = "${bg5}60";
    "tab.border" = "${colors.bg}";
    "tab.activeBorder" = "${colors.accent}d0";
    "tab.inactiveBackground" = "${colors.bg}";
    "tab.hoverBackground" = "${colors.bg}";
    "tab.hoverForeground" = "${colors.fg}";
    "tab.activeBackground" = "${colors.bg}";
    "tab.activeForeground" = "${colors.fg}";
    "tab.inactiveForeground" = "${colors.smoke}";
    "tab.unfocusedActiveForeground" = "#a5ada7";
    "tab.unfocusedActiveBorder" = "#8b938d";
    "tab.unfocusedInactiveForeground" = "${colors.smoke}";
    "tab.unfocusedHoverForeground" = "${colors.fg}";
    "tab.lastPinnedBorder" = "${colors.accent}d0";
    "editor.background" = "${colors.bg}";
    "editor.foreground" = "${colors.fg}";
    "editorLineNumber.foreground" = "${colors.smoke}a0";
    "editorLineNumber.activeForeground" = "#a5ada7e0";
    "editorCursor.foreground" = "${colors.fg}";
    "editor.selectionBackground" = "${colors.selectionBg}";
    "editor.selectionForeground" = "${colors.selectionFg}";
    "editor.selectionHighlightBackground" = "${colors.selectionBg}40";
    "editor.inactiveSelectionBackground" = "${colors.selectionBg}70";
    "editor.wordHighlightBackground" = "${colors.selectionBg}58";
    "editor.wordHighlightStrongBackground" = "${colors.selectionBg}b0";
    "editor.hoverHighlightBackground" = "${colors.selectionBg}b0";
    "editor.findMatchBackground" = "#b5633440";
    "editor.findMatchHighlightBackground" = "#6d8c4340";
    "editor.findRangeHighlightBackground" = "${colors.selectionBg}60";
    "editor.lineHighlightBorder" = "${bg5}00";
    "editor.lineHighlightBackground" = "${colors.surfaceDark}90";
    "editor.rangeHighlightBackground" = "${colors.surfaceDark}80";
    "editor.symbolHighlightBackground" = "#45818d40";
    "editorLink.activeForeground" = "${colors.accent}";
    "editorWhitespace.foreground" = "${bg4}";
    "editorIndentGuide.background" = "#a5ada720";
    "editorIndentGuide.activeBackground" = "#a5ada750";
    "editorInlayHint.background" = "${colors.bg}00";
    "editorInlayHint.foreground" = "${colors.smoke}a0";
    "editorInlayHint.typeBackground" = "${colors.bg}00";
    "editorInlayHint.typeForeground" = "${colors.smoke}a0";
    "editorInlayHint.parameterBackground" = "${colors.bg}00";
    "editorInlayHint.parameterForeground" = "${colors.smoke}a0";
    "editorRuler.foreground" = "${bg4}a0";
    "editorCodeLens.foreground" = "${colors.smoke}a0";
    "editor.foldBackground" = "${bg5}80";
    "editorBracketMatch.border" = "${colors.bg}00";
    "editorBracketMatch.background" = "${bg5}";
    "editorBracketHighlight.foreground1" = "${colors.coral}";
    "editorBracketHighlight.foreground2" = "${colors.gold}";
    "editorBracketHighlight.foreground3" = "${colors.accent}";
    "editorBracketHighlight.foreground4" = "${colors.accent2}";
    "editorBracketHighlight.foreground5" = "${colors.apricot}";
    "editorBracketHighlight.foreground6" = "${colors.c5}";
    "editorBracketHighlight.unexpectedBracket.foreground" = "#8b938d";
    "editorOverviewRuler.border" = "${colors.bg}00";
    "editorOverviewRuler.findMatchForeground" = "#388772";
    "editorOverviewRuler.rangeHighlightForeground" = "#388772";
    "editorOverviewRuler.selectionHighlightForeground" = "#388772";
    "editorOverviewRuler.wordHighlightForeground" = "${bg5}";
    "editorOverviewRuler.wordHighlightStrongForeground" = "${bg5}";
    "editorOverviewRuler.modifiedForeground" = "#45818da0";
    "editorOverviewRuler.addedForeground" = "#6d8c43a0";
    "editorOverviewRuler.deletedForeground" = "#b84e54a0";
    "editorOverviewRuler.errorForeground" = "${colors.coral}";
    "editorOverviewRuler.warningForeground" = "${colors.gold}";
    "editorOverviewRuler.infoForeground" = "${colors.c5}";
    "editorOverviewRuler.currentContentForeground" = "#45818d";
    "editorOverviewRuler.incomingContentForeground" = "#388772";
    "editorOverviewRuler.commonContentForeground" = "#8b938d";
    "problemsErrorIcon.foreground" = "${colors.coral}";
    "problemsWarningIcon.foreground" = "${colors.gold}";
    "problemsInfoIcon.foreground" = "${colors.accent2}";
    "editorUnnecessaryCode.border" = "${colors.bg}";
    "editorUnnecessaryCode.opacity" = "${bgDim}80";
    "editorError.foreground" = "#b84e54";
    "editorWarning.foreground" = "#a8843e";
    "editorInfo.foreground" = "#45818d";
    "editorHint.foreground" = "#9a526e";
    "editorError.background" = "#b84e5400";
    "editorWarning.background" = "#a8843e00";
    "editorInfo.background" = "#45818d00";
    "editorGutter.background" = "${colors.bg}00";
    "editorGutter.modifiedBackground" = "#45818da0";
    "editorGutter.addedBackground" = "#6d8c43a0";
    "editorGutter.deletedBackground" = "#b84e54a0";
    "editorGutter.commentRangeForeground" = "${colors.smoke}";
    "diffEditor.insertedTextBackground" = "#38877230";
    "diffEditor.removedTextBackground" = "#b84e5430";
    "diffEditor.diagonalFill" = "${bg5}";
    "editorSuggestWidget.background" = "${colors.surfaceDark}";
    "editorSuggestWidget.foreground" = "${colors.fg}";
    "editorSuggestWidget.highlightForeground" = "${colors.accent}";
    "editorSuggestWidget.selectedBackground" = "${bg4}";
    "editorSuggestWidget.border" = "${colors.surfaceDark}";
    "editorWidget.background" = "${colors.bg}";
    "editorWidget.foreground" = "${colors.fg}";
    "editorWidget.border" = "${bg5}";
    "editorHoverWidget.background" = "${colors.c0}";
    "editorHoverWidget.border" = "${bg4}";
    "editorGhostText.background" = "${colors.bg}00";
    "editorGhostText.foreground" = "${colors.smoke}a0";
    "editorMarkerNavigation.background" = "${colors.c0}";
    "editorMarkerNavigationError.background" = "#b84e5480";
    "editorMarkerNavigationWarning.background" = "#a8843e80";
    "editorMarkerNavigationInfo.background" = "#45818d80";
    "peekView.border" = "${bg4}";
    "peekViewEditor.background" = "${colors.c0}";
    "peekViewEditor.matchHighlightBackground" = "#a8843e50";
    "peekViewEditorGutter.background" = "${colors.c0}";
    "peekViewResult.fileForeground" = "${colors.fg}";
    "peekViewResult.lineForeground" = "#a5ada7";
    "peekViewResult.matchHighlightBackground" = "#a8843e50";
    "peekViewResult.selectionBackground" = "#38877250";
    "peekViewResult.selectionForeground" = "${colors.fg}";
    "peekViewTitleDescription.foreground" = "${colors.fg}";
    "peekViewTitleLabel.foreground" = "${colors.accent}";
    "peekViewResult.background" = "${colors.c0}";
    "peekViewTitle.background" = "${bg4}";
    "pickerGroup.border" = "${colors.accent}1a";
    "terminal.foreground" = "${colors.fg}";
    "terminalCursor.foreground" = "${colors.fg}";
    "terminal.selectionBackground" = "${colors.selectionBg}";
    "terminal.selectionForeground" = "${colors.selectionFg}";
    "terminal.ansiBlack" = "${colors.c0}";
    "terminal.ansiBlue" = "${colors.accent2}";
    "terminal.ansiBrightBlack" = "#8b938d";
    "terminal.ansiBrightBlue" = "${colors.accent2}";
    "terminal.ansiBrightCyan" = "${colors.c6}";
    "terminal.ansiBrightGreen" = "${colors.accent}";
    "terminal.ansiBrightMagenta" = "${colors.c5}";
    "terminal.ansiBrightRed" = "${colors.coral}";
    "terminal.ansiBrightWhite" = "${colors.fg}";
    "terminal.ansiBrightYellow" = "${colors.gold}";
    "terminal.ansiCyan" = "${colors.c6}";
    "terminal.ansiGreen" = "${colors.accent}";
    "terminal.ansiMagenta" = "${colors.c5}";
    "terminal.ansiRed" = "${colors.coral}";
    "terminal.ansiWhite" = "${colors.fg}";
    "terminal.ansiYellow" = "${colors.gold}";
    "debugToolBar.background" = "${colors.bg}";
    "debugTokenExpression.name" = "${colors.accent2}";
    "debugTokenExpression.value" = "${colors.accent}";
    "debugTokenExpression.string" = "${colors.gold}";
    "debugTokenExpression.boolean" = "${colors.c5}";
    "debugTokenExpression.number" = "${colors.c5}";
    "debugTokenExpression.error" = "${colors.coral}";
    "debugIcon.breakpointForeground" = "${colors.coral}";
    "debugIcon.breakpointDisabledForeground" = "#b84e54";
    "debugIcon.breakpointUnverifiedForeground" = "#a5ada7";
    "debugIcon.breakpointCurrentStackframeForeground" = "${colors.accent2}";
    "debugIcon.breakpointStackframeForeground" = "${colors.coral}";
    "debugIcon.startForeground" = "${colors.c6}";
    "debugIcon.pauseForeground" = "${colors.gold}";
    "debugIcon.stopForeground" = "${colors.coral}";
    "debugIcon.disconnectForeground" = "${colors.c5}";
    "debugIcon.restartForeground" = "${colors.c6}";
    "debugIcon.stepOverForeground" = "${colors.accent2}";
    "debugIcon.stepIntoForeground" = "${colors.accent2}";
    "debugIcon.stepOutForeground" = "${colors.accent2}";
    "debugIcon.continueForeground" = "${colors.accent2}";
    "debugIcon.stepBackForeground" = "${colors.accent2}";
    "debugConsole.infoForeground" = "${colors.accent}";
    "debugConsole.warningForeground" = "${colors.gold}";
    "debugConsole.errorForeground" = "${colors.coral}";
    "debugConsole.sourceForeground" = "${colors.c5}";
    "debugConsoleInputIcon.foreground" = "${colors.c6}";
    "merge.incomingHeaderBackground" = "#38877280";
    "merge.incomingContentBackground" = "#38877240";
    "merge.currentHeaderBackground" = "#45818d80";
    "merge.currentContentBackground" = "#45818d40";
    "merge.border" = "${colors.bg}00";
    "panel.background" = "${colors.bg}";
    "panel.border" = "${colors.bg}";
    "panelInput.border" = "${bg5}";
    "panelTitle.activeForeground" = "${colors.fg}";
    "panelTitle.activeBorder" = "${colors.accent}d0";
    "panelTitle.inactiveForeground" = "#8b938d";
    "panelSection.border" = "${bg1}";
    "panelSectionHeader.background" = "${colors.bg}";
    "imagePreview.border" = "${colors.bg}";
    "statusBar.background" = "${colors.bg}";
    "statusBar.foreground" = "#a5ada7";
    "statusBar.border" = "${colors.bg}";
    "statusBar.debuggingForeground" = "${colors.apricot}";
    "statusBar.debuggingBackground" = "${colors.bg}";
    "statusBar.noFolderBackground" = "${colors.bg}";
    "statusBar.noFolderForeground" = "#a5ada7";
    "statusBar.noFolderBorder" = "${colors.bg}";
    "statusBarItem.hoverBackground" = "${bg4}a0";
    "statusBarItem.activeBackground" = "${bg4}70";
    "statusBarItem.prominentForeground" = "${colors.fg}";
    "statusBarItem.prominentBackground" = "${colors.bg}";
    "statusBarItem.prominentHoverBackground" = "${bg4}a0";
    "statusBarItem.remoteBackground" = "${colors.bg}";
    "statusBarItem.remoteForeground" = "#a5ada7";
    "statusBarItem.errorBackground" = "${colors.bg}";
    "statusBarItem.errorForeground" = "${colors.coral}";
    "statusBarItem.warningBackground" = "${colors.bg}";
    "statusBarItem.warningForeground" = "${colors.gold}";
    "titleBar.activeBackground" = "${colors.bg}";
    "titleBar.activeForeground" = "#a5ada7";
    "titleBar.inactiveBackground" = "${colors.bg}";
    "titleBar.inactiveForeground" = "${colors.smoke}";
    "titleBar.border" = "${colors.bg}";
    "menubar.selectionBackground" = "${colors.bg}";
    "menubar.selectionBorder" = "${colors.bg}";
    "menu.foreground" = "#a5ada7";
    "menu.background" = "${colors.bg}";
    "menu.selectionForeground" = "${colors.fg}";
    "menu.selectionBackground" = "${colors.c0}";
    "gitDecoration.addedResourceForeground" = "${colors.accent}a0";
    "gitDecoration.modifiedResourceForeground" = "${colors.accent2}a0";
    "gitDecoration.deletedResourceForeground" = "${colors.coral}a0";
    "gitDecoration.untrackedResourceForeground" = "${colors.gold}a0";
    "gitDecoration.ignoredResourceForeground" = "${bg5}";
    "gitDecoration.conflictingResourceForeground" = "${colors.c5}a0";
    "gitDecoration.submoduleResourceForeground" = "${colors.apricot}a0";
    "gitDecoration.stageDeletedResourceForeground" = "${colors.c6}a0";
    "gitDecoration.stageModifiedResourceForeground" = "${colors.c6}a0";
    "notificationCenterHeader.foreground" = "${colors.fg}";
    "notificationCenterHeader.background" = "${colors.surfaceDark}";
    "notifications.foreground" = "${colors.fg}";
    "notifications.background" = "${colors.bg}";
    "notificationLink.foreground" = "${colors.accent}";
    "notificationsErrorIcon.foreground" = "${colors.coral}";
    "notificationsWarningIcon.foreground" = "${colors.gold}";
    "notificationsInfoIcon.foreground" = "${colors.accent2}";
    "extensionButton.prominentForeground" = "${colors.bg}";
    "extensionButton.prominentBackground" = "${colors.accent}";
    "extensionButton.prominentHoverBackground" = "${colors.accent}d0";
    "extensionBadge.remoteBackground" = "${colors.accent}";
    "extensionBadge.remoteForeground" = "${colors.bg}";
    "extensionIcon.starForeground" = "${colors.c6}";
    "extensionIcon.verifiedForeground" = "${colors.accent}";
    "extensionIcon.preReleaseForeground" = "${colors.apricot}";
    "pickerGroup.foreground" = "${colors.fg}";
    "quickInputTitle.background" = "${colors.c0}";
    "keybindingLabel.background" = "${colors.bg}00";
    "keybindingLabel.foreground" = "${colors.fg}";
    "keybindingLabel.border" = "${bg1}";
    "keybindingLabel.bottomBorder" = "${bg1}";
    "keybindingTable.headerBackground" = "${colors.surfaceDark}";
    "keybindingTable.rowsBackground" = "${colors.c0}";
    "settings.headerForeground" = "#a5ada7";
    "settings.numberInputBackground" = "${colors.bg}";
    "settings.numberInputForeground" = "${colors.c5}";
    "settings.numberInputBorder" = "${bg5}";
    "settings.textInputBackground" = "${colors.bg}";
    "settings.textInputForeground" = "${colors.accent2}";
    "settings.textInputBorder" = "${bg5}";
    "settings.checkboxBackground" = "${colors.bg}";
    "settings.checkboxForeground" = "${colors.apricot}";
    "settings.checkboxBorder" = "${bg5}";
    "settings.dropdownBackground" = "${colors.bg}";
    "settings.dropdownForeground" = "${colors.c6}";
    "settings.dropdownBorder" = "${bg5}";
    "settings.modifiedItemIndicator" = "${colors.smoke}";
    "settings.focusedRowBackground" = "${colors.c0}";
    "settings.rowHoverBackground" = "${colors.c0}";
    "editorLightBulb.foreground" = "${colors.gold}";
    "editorLightBulbAutoFix.foreground" = "${colors.c6}";
    "welcomePage.progress.foreground" = "${colors.accent}";
    "welcomePage.tileHoverBackground" = "${colors.c0}";
    "welcomePage.buttonBackground" = "${colors.c0}";
    "welcomePage.buttonHoverBackground" = "${colors.c0}a0";
    "walkThrough.embeddedEditorBackground" = "${bg1}";
    "breadcrumb.foreground" = "#8b938d";
    "breadcrumb.focusForeground" = "${colors.fg}";
    "breadcrumb.activeSelectionForeground" = "${colors.fg}";
    "symbolIcon.colorForeground" = "${colors.fg}";
    "symbolIcon.snippetForeground" = "${colors.fg}";
    "symbolIcon.fieldForeground" = "${colors.fg}";
    "symbolIcon.fileForeground" = "${colors.fg}";
    "symbolIcon.folderForeground" = "${colors.fg}";
    "symbolIcon.textForeground" = "${colors.fg}";
    "symbolIcon.unitForeground" = "${colors.fg}";
    "symbolIcon.keywordForeground" = "${colors.coral}";
    "symbolIcon.operatorForeground" = "${colors.apricot}";
    "symbolIcon.classForeground" = "${colors.gold}";
    "symbolIcon.eventForeground" = "${colors.gold}";
    "symbolIcon.interfaceForeground" = "${colors.gold}";
    "symbolIcon.structForeground" = "${colors.gold}";
    "symbolIcon.functionForeground" = "${colors.accent}";
    "symbolIcon.keyForeground" = "${colors.accent}";
    "symbolIcon.methodForeground" = "${colors.accent}";
    "symbolIcon.stringForeground" = "${colors.accent}";
    "symbolIcon.constantForeground" = "${colors.c6}";
    "symbolIcon.enumeratorMemberForeground" = "${colors.c6}";
    "symbolIcon.nullForeground" = "${colors.c6}";
    "symbolIcon.propertyForeground" = "${colors.c6}";
    "symbolIcon.typeParameterForeground" = "${colors.c6}";
    "symbolIcon.arrayForeground" = "${colors.accent2}";
    "symbolIcon.referenceForeground" = "${colors.accent2}";
    "symbolIcon.variableForeground" = "${colors.accent2}";
    "symbolIcon.booleanForeground" = "${colors.c5}";
    "symbolIcon.constructorForeground" = "${colors.c5}";
    "symbolIcon.enumeratorForeground" = "${colors.c5}";
    "symbolIcon.moduleForeground" = "${colors.c5}";
    "symbolIcon.namespaceForeground" = "${colors.c5}";
    "symbolIcon.numberForeground" = "${colors.c5}";
    "symbolIcon.objectForeground" = "${colors.c5}";
    "symbolIcon.packageForeground" = "${colors.c5}";
    "editor.snippetTabstopHighlightBackground" = "${colors.surfaceDark}";
    "editor.snippetFinalTabstopHighlightBackground" = "#6d8c4340";
    "editor.snippetFinalTabstopHighlightBorder" = "${colors.bg}";
    "charts.red" = "${colors.coral}";
    "charts.orange" = "${colors.apricot}";
    "charts.yellow" = "${colors.gold}";
    "charts.green" = "${colors.accent}";
    "charts.blue" = "${colors.accent2}";
    "charts.purple" = "${colors.c5}";
    "charts.foreground" = "${colors.fg}";
    "ports.iconRunningProcessForeground" = "${colors.apricot}";
    "sash.hoverBorder" = "${bg4}";
    "notebook.cellBorderColor" = "${bg5}";
    "notebook.cellStatusBarItemHoverBackground" = "${colors.c0}";
    "notebook.focusedCellBackground" = "${colors.bg}";
    "notebook.cellHoverBackground" = "${colors.bg}";
    "notebook.outputContainerBackgroundColor" = "${bg1}";
    "notebookStatusSuccessIcon.foreground" = "${colors.accent}";
    "notebookStatusErrorIcon.foreground" = "${colors.coral}";
    "notebookStatusRunningIcon.foreground" = "${colors.accent2}";
    "notebook.focusedCellBorder" = "${bg5}";
    "notebook.focusedEditorBorder" = "${bg5}";
    "notebook.selectedCellBorder" = "${bg5}";
    "notebook.focusedRowBorder" = "${bg5}";
    "notebook.inactiveFocusedCellBorder" = "${bg5}";
    "notebook.cellToolbarSeparator" = "${bg5}";
    "testing.iconFailed" = "${colors.coral}";
    "testing.iconErrored" = "${colors.coral}";
    "testing.iconPassed" = "${colors.c6}";
    "testing.runAction" = "${colors.c6}";
    "testing.iconQueued" = "${colors.accent2}";
    "testing.iconUnset" = "${colors.gold}";
    "testing.iconSkipped" = "${colors.c5}";
    "gitlens.gutterBackgroundColor" = "${colors.bg}";
    "gitlens.gutterForegroundColor" = "${colors.fg}";
    "gitlens.gutterUncommittedForegroundColor" = "${colors.accent2}";
    "gitlens.trailingLineForegroundColor" = "#8b938d";
    "gitlens.lineHighlightBackgroundColor" = "${colors.c0}";
    "gitlens.lineHighlightOverviewRulerColor" = "${colors.accent}";
    "gitlens.closedPullRequestIconColor" = "${colors.coral}";
    "gitlens.openPullRequestIconColor" = "${colors.c6}";
    "gitlens.mergedPullRequestIconColor" = "${colors.c5}";
    "gitlens.unpushlishedChangesIconColor" = "${colors.accent2}";
    "gitlens.unpublishedCommitIconColor" = "${colors.gold}";
    "gitlens.unpulledChangesIconColor" = "${colors.apricot}";
    "gitlens.decorations.addedForegroundColor" = "${colors.accent}";
    "gitlens.decorations.copiedForegroundColor" = "${colors.c5}";
    "gitlens.decorations.deletedForegroundColor" = "${colors.coral}";
    "gitlens.decorations.ignoredForegroundColor" = "#a5ada7";
    "gitlens.decorations.modifiedForegroundColor" = "${colors.accent2}";
    "gitlens.decorations.untrackedForegroundColor" = "${colors.gold}";
    "gitlens.decorations.renamedForegroundColor" = "${colors.c5}";
    "gitlens.decorations.branchAheadForegroundColor" = "${colors.c6}";
    "gitlens.decorations.branchBehindForegroundColor" = "${colors.apricot}";
    "gitlens.decorations.branchDivergedForegroundColor" = "${colors.gold}";
    "gitlens.decorations.branchUpToDateForegroundColor" = "${colors.fg}";
    "gitlens.decorations.branchUnpublishedForegroundColor" = "${colors.accent2}";
    "gitlens.decorations.branchMissingUpstreamForegroundColor" = "${colors.coral}";
    "issues.open" = "${colors.c6}";
    "issues.closed" = "${colors.coral}";
    "rust_analyzer.inlayHints.foreground" = "${colors.smoke}a0";
    "rust_analyzer.inlayHints.background" = "${colors.bg}00";
    "rust_analyzer.syntaxTreeBorder" = "${colors.coral}";
  };

  tokenColorCustomizations = {
    textMateRules = [
      {
        "name" = "Keyword";
        "scope" =
          "keyword, storage.type.function, storage.type.class, storage.type.enum, storage.type.interface, storage.type.property, keyword.operator.new, keyword.operator.expression, keyword.operator.new, keyword.operator.delete, storage.type.extends";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Debug";
        "scope" = "keyword.other.debugger";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Storage";
        "scope" =
          "storage, modifier, keyword.var, entity.name.tag, keyword.control.case, keyword.control.switch";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Operator";
        "scope" = "keyword.operator";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "String";
        "scope" =
          "string, punctuation.definition.string.end, punctuation.definition.string.begin, punctuation.definition.string.template.begin, punctuation.definition.string.template.end";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Attribute";
        "scope" = "entity.other.attribute-name";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "String Escape";
        "scope" =
          "constant.character.escape, punctuation.quasi.element, punctuation.definition.template-expression, punctuation.section.embedded, storage.type.format, constant.other.placeholder, constant.other.placeholder, variable.interpolation";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Function";
        "scope" =
          "entity.name.function, support.function, meta.function, meta.function-call, meta.definition.method";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Preproc";
        "scope" =
          "keyword.control.at-rule, keyword.control.import, keyword.control.export, storage.type.namespace, punctuation.decorator, keyword.control.directive, keyword.preprocessor, punctuation.definition.preprocessor, punctuation.definition.directive, keyword.other.import, keyword.other.package, entity.name.type.namespace, entity.name.scope-resolution, keyword.other.using, keyword.package, keyword.import, keyword.map";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Annotation";
        "scope" = "storage.type.annotation";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Label";
        "scope" = "entity.name.label, constant.other.label";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Modules";
        "scope" =
          "support.module, support.node, support.other.module, support.type.object.module, entity.name.type.module, entity.name.type.class.module, keyword.control.module";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Type";
        "scope" = "storage.type, support.type, entity.name.type, keyword.type";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Class";
        "scope" =
          "entity.name.type.class, support.class, entity.name.class, entity.other.inherited-class, storage.class";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Number";
        "scope" = "constant.numeric";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Boolean";
        "scope" = "constant.language.boolean";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Macro";
        "scope" = "entity.name.function.preprocessor";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Special identifier";
        "scope" =
          "variable.language.this, variable.language.self, variable.language.super, keyword.other.this, variable.language.special, constant.language.null, constant.language.undefined, constant.language.nan";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Constant";
        "scope" = "constant.language, support.constant";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Identifier";
        "scope" = "variable, support.variable, meta.definition.variable";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Property";
        "scope" =
          "variable.object.property, support.variable.property, variable.other.property, variable.other.object.property, variable.other.enummember, variable.other.member, meta.object-literal.key";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Delimiter";
        "scope" = "punctuation, meta.brace, meta.delimiter, meta.bracket";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Markdown heading1";
        "scope" = "heading.1.markdown, markup.heading.setext.1.markdown";
        "settings" = {
          "foreground" = "${colors.coral}";
          "fontStyle" = "bold";
        };
      }
      {
        "name" = "Markdown heading2";
        "scope" = "heading.2.markdown, markup.heading.setext.2.markdown";
        "settings" = {
          "foreground" = "${colors.apricot}";
          "fontStyle" = "bold";
        };
      }
      {
        "name" = "Markdown heading3";
        "scope" = "heading.3.markdown";
        "settings" = {
          "foreground" = "${colors.gold}";
          "fontStyle" = "bold";
        };
      }
      {
        "name" = "Markdown heading4";
        "scope" = "heading.4.markdown";
        "settings" = {
          "foreground" = "${colors.accent}";
          "fontStyle" = "bold";
        };
      }
      {
        "name" = "Markdown heading5";
        "scope" = "heading.5.markdown";
        "settings" = {
          "foreground" = "${colors.accent2}";
          "fontStyle" = "bold";
        };
      }
      {
        "name" = "Markdown heading6";
        "scope" = "heading.6.markdown";
        "settings" = {
          "foreground" = "${colors.c5}";
          "fontStyle" = "bold";
        };
      }
      {
        "name" = "Markdown heading delimiter";
        "scope" = "punctuation.definition.heading.markdown";
        "settings" = {
          "foreground" = "#8b938d";
          "fontStyle" = "regular";
        };
      }
      {
        "name" = "Markdown link";
        "scope" =
          "string.other.link.title.markdown, constant.other.reference.link.markdown, string.other.link.description.markdown";
        "settings" = {
          "foreground" = "${colors.c5}";
          "fontStyle" = "regular";
        };
      }
      {
        "name" = "Markdown link text";
        "scope" = "markup.underline.link.image.markdown, markup.underline.link.markdown";
        "settings" = {
          "foreground" = "${colors.accent}";
          "fontStyle" = "underline";
        };
      }
      {
        "name" = "Markdown delimiter";
        "scope" =
          "punctuation.definition.string.begin.markdown, punctuation.definition.string.end.markdown, punctuation.definition.italic.markdown, punctuation.definition.quote.begin.markdown, punctuation.definition.metadata.markdown, punctuation.separator.key-value.markdown, punctuation.definition.constant.markdown";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "Markdown bold delimiter";
        "scope" = "punctuation.definition.bold.markdown";
        "settings" = {
          "foreground" = "#8b938d";
          "fontStyle" = "regular";
        };
      }
      {
        "name" = "Markdown separator delimiter";
        "scope" =
          "meta.separator.markdown, punctuation.definition.constant.begin.markdown, punctuation.definition.constant.end.markdown";
        "settings" = {
          "foreground" = "#8b938d";
          "fontStyle" = "bold";
        };
      }
      {
        "name" = "Markdown italic";
        "scope" = "markup.italic";
        "settings" = {
          "fontStyle" = "italic";
        };
      }
      {
        "name" = "Markdown bold";
        "scope" = "markup.bold";
        "settings" = {
          "fontStyle" = "bold";
        };
      }
      {
        "name" = "Markdown bold italic";
        "scope" = "markup.bold markup.italic, markup.italic markup.bold";
        "settings" = {
          "fontStyle" = "italic bold";
        };
      }
      {
        "name" = "Markdown code delimiter";
        "scope" = "punctuation.definition.markdown, punctuation.definition.raw.markdown";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Markdown code type";
        "scope" = "fenced_code.block.language";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Markdown code block";
        "scope" = "markup.fenced_code.block.markdown, markup.inline.raw.string.markdown";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Markdown list mark";
        "scope" = "punctuation.definition.list.begin.markdown";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "reStructuredText heading";
        "scope" = "punctuation.definition.heading.restructuredtext";
        "settings" = {
          "foreground" = "${colors.apricot}";
          "fontStyle" = "bold";
        };
      }
      {
        "name" = "reStructuredText delimiter";
        "scope" =
          "punctuation.definition.field.restructuredtext, punctuation.separator.key-value.restructuredtext, punctuation.definition.directive.restructuredtext, punctuation.definition.constant.restructuredtext, punctuation.definition.italic.restructuredtext, punctuation.definition.table.restructuredtext";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "reStructuredText delimiter bold";
        "scope" = "punctuation.definition.bold.restructuredtext";
        "settings" = {
          "foreground" = "#8b938d";
          "fontStyle" = "regular";
        };
      }
      {
        "name" = "reStructuredText aqua";
        "scope" =
          "entity.name.tag.restructuredtext, punctuation.definition.link.restructuredtext, punctuation.definition.raw.restructuredtext, punctuation.section.raw.restructuredtext";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "reStructuredText purple";
        "scope" = "constant.other.footnote.link.restructuredtext";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "reStructuredText red";
        "scope" = "support.directive.restructuredtext";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "reStructuredText green";
        "scope" =
          "entity.name.directive.restructuredtext, markup.raw.restructuredtext, markup.raw.inner.restructuredtext, string.other.link.title.restructuredtext";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "LaTex delimiter";
        "scope" =
          "punctuation.definition.function.latex, punctuation.definition.function.tex, punctuation.definition.keyword.latex, constant.character.newline.tex, punctuation.definition.keyword.tex";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "LaTex red";
        "scope" = "support.function.be.latex";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "LaTex orange";
        "scope" =
          "support.function.section.latex, keyword.control.table.cell.latex, keyword.control.table.newline.latex";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "LaTex yellow";
        "scope" =
          "support.class.latex, variable.parameter.latex, variable.parameter.function.latex, variable.parameter.definition.label.latex, constant.other.reference.label.latex";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "LaTex purple";
        "scope" = "keyword.control.preamble.latex";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Html grey";
        "scope" = "punctuation.separator.namespace.xml";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "Html orange";
        "scope" = "entity.name.tag.html, entity.name.tag.xml, entity.name.tag.localname.xml";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Html yellow";
        "scope" =
          "entity.other.attribute-name.html, entity.other.attribute-name.xml, entity.other.attribute-name.localname.xml";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Html green";
        "scope" =
          "string.quoted.double.html, string.quoted.single.html, punctuation.definition.string.begin.html, punctuation.definition.string.end.html, punctuation.separator.key-value.html, punctuation.definition.string.begin.xml, punctuation.definition.string.end.xml, string.quoted.double.xml, string.quoted.single.xml, punctuation.definition.tag.begin.html, punctuation.definition.tag.end.html, punctuation.definition.tag.xml, meta.tag.xml, meta.tag.preprocessor.xml, meta.tag.other.html, meta.tag.block.any.html, meta.tag.inline.any.html";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Html purple";
        "scope" = "variable.language.documentroot.xml, meta.tag.sgml.doctype.xml";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Proto yellow";
        "scope" = "storage.type.proto";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Proto green";
        "scope" =
          "string.quoted.double.proto.syntax, string.quoted.single.proto.syntax, string.quoted.double.proto, string.quoted.single.proto";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Proto aqua";
        "scope" = "entity.name.class.proto, entity.name.class.message.proto";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "CSS grey";
        "scope" =
          "punctuation.definition.entity.css, punctuation.separator.key-value.css, punctuation.terminator.rule.css, punctuation.separator.list.comma.css";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "CSS red";
        "scope" = "entity.other.attribute-name.class.css";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "CSS orange";
        "scope" = "keyword.other.unit";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "CSS yellow";
        "scope" =
          "entity.other.attribute-name.pseudo-class.css, entity.other.attribute-name.pseudo-element.css";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "CSS green";
        "scope" =
          "string.quoted.single.css, string.quoted.double.css, support.constant.property-value.css, meta.property-value.css, punctuation.definition.string.begin.css, punctuation.definition.string.end.css, constant.numeric.css, support.constant.font-name.css, variable.parameter.keyframe-list.css";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "CSS aqua";
        "scope" = "support.type.property-name.css";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "CSS blue";
        "scope" = "support.type.vendored.property-name.css";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "CSS purple";
        "scope" =
          "entity.name.tag.css, entity.other.keyframe-offset.css, punctuation.definition.keyword.css, keyword.control.at-rule.keyframes.css, meta.selector.css";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "SASS grey";
        "scope" =
          "punctuation.definition.entity.scss, punctuation.separator.key-value.scss, punctuation.terminator.rule.scss, punctuation.separator.list.comma.scss";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "SASS orange";
        "scope" = "keyword.control.at-rule.keyframes.scss";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "SASS yellow";
        "scope" =
          "punctuation.definition.interpolation.begin.bracket.curly.scss, punctuation.definition.interpolation.end.bracket.curly.scss";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "SASS green";
        "scope" =
          "punctuation.definition.string.begin.scss, punctuation.definition.string.end.scss, string.quoted.double.scss, string.quoted.single.scss, constant.character.css.sass, meta.property-value.scss";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "SASS purple";
        "scope" =
          "keyword.control.at-rule.include.scss, keyword.control.at-rule.use.scss, keyword.control.at-rule.mixin.scss, keyword.control.at-rule.extend.scss, keyword.control.at-rule.import.scss";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Stylus white";
        "scope" = "meta.function.stylus";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Stylus yellow";
        "scope" = "entity.name.function.stylus";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "JavaScript white";
        "scope" = "string.unquoted.js";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "JavaScript grey";
        "scope" =
          "punctuation.accessor.js, punctuation.separator.key-value.js, punctuation.separator.label.js, keyword.operator.accessor.js";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "JavaScript red";
        "scope" = "punctuation.definition.block.tag.jsdoc";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "JavaScript orange";
        "scope" = "storage.type.js, storage.type.function.arrow.js";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "JSX white";
        "scope" = "JSXNested";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "JSX green";
        "scope" =
          "punctuation.definition.tag.jsx, entity.other.attribute-name.jsx, punctuation.definition.tag.begin.js.jsx, punctuation.definition.tag.end.js.jsx, entity.other.attribute-name.js.jsx";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "TypeScript white";
        "scope" = "entity.name.type.module.ts";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "TypeScript grey";
        "scope" =
          "keyword.operator.type.annotation.ts, punctuation.accessor.ts, punctuation.separator.key-value.ts";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "TypeScript green";
        "scope" = "punctuation.definition.tag.directive.ts, entity.other.attribute-name.directive.ts";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "TypeScript aqua";
        "scope" =
          "entity.name.type.ts, entity.name.type.interface.ts, entity.other.inherited-class.ts, entity.name.type.alias.ts, entity.name.type.class.ts, entity.name.type.enum.ts";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "TypeScript orange";
        "scope" = "storage.type.ts, storage.type.function.arrow.ts, storage.type.type.ts";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "TypeScript blue";
        "scope" = "entity.name.type.module.ts";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "TypeScript purple";
        "scope" = "keyword.control.import.ts, keyword.control.export.ts, storage.type.namespace.ts";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "TSX white";
        "scope" = "entity.name.type.module.tsx";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "TSX grey";
        "scope" =
          "keyword.operator.type.annotation.tsx, punctuation.accessor.tsx, punctuation.separator.key-value.tsx";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "TSX green";
        "scope" =
          "punctuation.definition.tag.directive.tsx, entity.other.attribute-name.directive.tsx, punctuation.definition.tag.begin.tsx, punctuation.definition.tag.end.tsx, entity.other.attribute-name.tsx";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "TSX aqua";
        "scope" =
          "entity.name.type.tsx, entity.name.type.interface.tsx, entity.other.inherited-class.tsx, entity.name.type.alias.tsx, entity.name.type.class.tsx, entity.name.type.enum.tsx";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "TSX blue";
        "scope" = "entity.name.type.module.tsx";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "TSX purple";
        "scope" = "keyword.control.import.tsx, keyword.control.export.tsx, storage.type.namespace.tsx";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "TSX orange";
        "scope" =
          "storage.type.tsx, storage.type.function.arrow.tsx, storage.type.type.tsx, support.class.component.tsx";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "CoffeeScript orange";
        "scope" = "storage.type.function.coffee";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "PureScript white";
        "scope" = "meta.type-signature.purescript";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "PureScript orange";
        "scope" =
          "keyword.other.double-colon.purescript, keyword.other.arrow.purescript, keyword.other.big-arrow.purescript";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "PureScript yellow";
        "scope" = "entity.name.function.purescript";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "PureScript green";
        "scope" =
          "string.quoted.single.purescript, string.quoted.double.purescript, punctuation.definition.string.begin.purescript, punctuation.definition.string.end.purescript, string.quoted.triple.purescript, entity.name.type.purescript";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "PureScript purple";
        "scope" = "support.other.module.purescript";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Dart grey";
        "scope" = "punctuation.dot.dart";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "Dart orange";
        "scope" = "storage.type.primitive.dart";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Dart yellow";
        "scope" = "support.class.dart";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Dart green";
        "scope" =
          "entity.name.function.dart, string.interpolated.single.dart, string.interpolated.double.dart";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Dart blue";
        "scope" = "variable.language.dart";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Dart purple";
        "scope" = "keyword.other.import.dart, storage.type.annotation.dart";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Pug red";
        "scope" = "entity.other.attribute-name.class.pug";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Pug orange";
        "scope" = "storage.type.function.pug";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Pug aqua";
        "scope" = "entity.other.attribute-name.tag.pug";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Pug purple";
        "scope" = "entity.name.tag.pug, storage.type.import.include.pug";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "C white";
        "scope" =
          "meta.function-call.c, storage.modifier.array.bracket.square.c, meta.function.definition.parameters.c";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "C grey";
        "scope" = "punctuation.separator.dot-access.c, constant.character.escape.line-continuation.c";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "C red";
        "scope" =
          "keyword.control.directive.include.c, punctuation.definition.directive.c, keyword.control.directive.pragma.c, keyword.control.directive.line.c, keyword.control.directive.define.c, keyword.control.directive.conditional.c, keyword.control.directive.diagnostic.error.c, keyword.control.directive.undef.c, keyword.control.directive.conditional.ifdef.c, keyword.control.directive.endif.c, keyword.control.directive.conditional.ifndef.c, keyword.control.directive.conditional.if.c, keyword.control.directive.else.c";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "C orange";
        "scope" = "punctuation.separator.pointer-access.c";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "C aqua";
        "scope" = "variable.other.member.c";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "C++ white";
        "scope" =
          "meta.function-call.cpp, storage.modifier.array.bracket.square.cpp, meta.function.definition.parameters.cpp, meta.body.function.definition.cpp";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "C++ grey";
        "scope" = "punctuation.separator.dot-access.cpp, constant.character.escape.line-continuation.cpp";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "C++ red";
        "scope" =
          "keyword.control.directive.include.cpp, punctuation.definition.directive.cpp, keyword.control.directive.pragma.cpp, keyword.control.directive.line.cpp, keyword.control.directive.define.cpp, keyword.control.directive.conditional.cpp, keyword.control.directive.diagnostic.error.cpp, keyword.control.directive.undef.cpp, keyword.control.directive.conditional.ifdef.cpp, keyword.control.directive.endif.cpp, keyword.control.directive.conditional.ifndef.cpp, keyword.control.directive.conditional.if.cpp, keyword.control.directive.else.cpp, storage.type.namespace.definition.cpp, keyword.other.using.directive.cpp, storage.type.struct.cpp";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "C++ orange";
        "scope" =
          "punctuation.separator.pointer-access.cpp, punctuation.section.angle-brackets.begin.template.call.cpp, punctuation.section.angle-brackets.end.template.call.cpp";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "C++ aqua";
        "scope" = "variable.other.member.cpp";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "C# red";
        "scope" = "keyword.other.using.cs";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "C# yellow";
        "scope" =
          "keyword.type.cs, constant.character.escape.cs, punctuation.definition.interpolation.begin.cs, punctuation.definition.interpolation.end.cs";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "C# green";
        "scope" =
          "string.quoted.double.cs, string.quoted.single.cs, punctuation.definition.string.begin.cs, punctuation.definition.string.end.cs";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "C# aqua";
        "scope" = "variable.other.object.property.cs";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "C# purple";
        "scope" = "entity.name.type.namespace.cs";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "F# white";
        "scope" = "keyword.symbol.fsharp, constant.language.unit.fsharp";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "F# yellow";
        "scope" = "keyword.format.specifier.fsharp, entity.name.type.fsharp";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "F# green";
        "scope" =
          "string.quoted.double.fsharp, string.quoted.single.fsharp, punctuation.definition.string.begin.fsharp, punctuation.definition.string.end.fsharp";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "F# blue";
        "scope" = "entity.name.section.fsharp";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "F# purple";
        "scope" = "support.function.attribute.fsharp";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Java grey";
        "scope" = "punctuation.separator.java, punctuation.separator.period.java";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "Java red";
        "scope" = "keyword.other.import.java, keyword.other.package.java";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Java orange";
        "scope" = "storage.type.function.arrow.java, keyword.control.ternary.java";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Java aqua";
        "scope" = "variable.other.property.java";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Java purple";
        "scope" =
          "variable.language.wildcard.java, storage.modifier.import.java, storage.type.annotation.java, punctuation.definition.annotation.java, storage.modifier.package.java, entity.name.type.module.java";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Kotlin red";
        "scope" = "keyword.other.import.kotlin";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Kotlin orange";
        "scope" = "storage.type.kotlin";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Kotlin aqua";
        "scope" = "constant.language.kotlin";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Kotlin purple";
        "scope" = "entity.name.package.kotlin, storage.type.annotation.kotlin";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Scala purple";
        "scope" = "entity.name.package.scala";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Scala blue";
        "scope" = "constant.language.scala";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Scala aqua";
        "scope" = "entity.name.import.scala";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Scala green";
        "scope" =
          "string.quoted.double.scala, string.quoted.single.scala, punctuation.definition.string.begin.scala, punctuation.definition.string.end.scala, string.quoted.double.interpolated.scala, string.quoted.single.interpolated.scala, string.quoted.triple.scala";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Scala yellow";
        "scope" = "entity.name.class, entity.other.inherited-class.scala";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Scala orange";
        "scope" = "keyword.declaration.stable.scala, keyword.other.arrow.scala";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Scala red";
        "scope" = "keyword.other.import.scala";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Groovy white";
        "scope" =
          "keyword.operator.navigation.groovy, meta.method.body.java, meta.definition.method.groovy, meta.definition.method.signature.java";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Scala grey";
        "scope" = "punctuation.separator.groovy";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "Scala red";
        "scope" =
          "keyword.other.import.groovy, keyword.other.package.groovy, keyword.other.import.static.groovy";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Groovy orange";
        "scope" = "storage.type.def.groovy";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Groovy green";
        "scope" = "variable.other.interpolated.groovy, meta.method.groovy";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Groovy aqua";
        "scope" = "storage.modifier.import.groovy, storage.modifier.package.groovy";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Groovy purple";
        "scope" = "storage.type.annotation.groovy";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Go red";
        "scope" = "keyword.type.go";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Go aqua";
        "scope" = "entity.name.package.go";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Go purple";
        "scope" = "keyword.import.go, keyword.package.go";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Rust white";
        "scope" = "entity.name.type.mod.rust";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Rust grey";
        "scope" = "keyword.operator.path.rust, keyword.operator.member-access.rust";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "Rust orange";
        "scope" = "storage.type.rust";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Rust aqua";
        "scope" = "support.constant.core.rust";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Rust purple";
        "scope" = "meta.attribute.rust, variable.language.rust, storage.type.module.rust";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Swift white";
        "scope" = "meta.function-call.swift, support.function.any-method.swift";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Swift aqua";
        "scope" = "support.variable.swift";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "PHP white";
        "scope" = "keyword.operator.class.php";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "PHP orange";
        "scope" = "storage.type.trait.php";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "PHP aqua";
        "scope" = "constant.language.php, support.other.namespace.php";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "PHP blue";
        "scope" =
          "storage.type.modifier.access.control.public.cpp, storage.type.modifier.access.control.private.cpp";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "PHP purple";
        "scope" = "keyword.control.import.include.php, storage.type.php";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Python white";
        "scope" = "meta.function-call.arguments.python";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Python grey";
        "scope" = "punctuation.definition.decorator.python, punctuation.separator.period.python";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "Python aqua";
        "scope" = "constant.language.python";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Python purple";
        "scope" = "keyword.control.import.python, keyword.control.import.from.python";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Lua aqua";
        "scope" = "constant.language.lua";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Lua blue";
        "scope" = "entity.name.class.lua";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Ruby white";
        "scope" = "meta.function.method.with-arguments.ruby";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Ruby grey";
        "scope" = "punctuation.separator.method.ruby";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "Ruby orange";
        "scope" = "keyword.control.pseudo-method.ruby, storage.type.variable.ruby";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Ruby green";
        "scope" = "keyword.other.special-method.ruby";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Ruby purple";
        "scope" = "keyword.control.module.ruby, punctuation.definition.constant.ruby";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Ruby yellow";
        "scope" =
          "string.regexp.character-class.ruby,string.regexp.interpolated.ruby,punctuation.definition.character-class.ruby,string.regexp.group.ruby, punctuation.section.regexp.ruby, punctuation.definition.group.ruby";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Ruby blue";
        "scope" = "variable.other.constant.ruby";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Haskell orange";
        "scope" =
          "keyword.other.arrow.haskell, keyword.other.big-arrow.haskell, keyword.other.double-colon.haskell";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Haskell yellow";
        "scope" = "storage.type.haskell";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Haskell green";
        "scope" =
          "constant.other.haskell, string.quoted.double.haskell, string.quoted.single.haskell, punctuation.definition.string.begin.haskell, punctuation.definition.string.end.haskell";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Haskell blue";
        "scope" = "entity.name.function.haskell";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Haskell aqua";
        "scope" = "entity.name.namespace, meta.preprocessor.haskell";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Julia red";
        "scope" = "keyword.control.import.julia, keyword.control.export.julia";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Julia orange";
        "scope" = "keyword.storage.modifier.julia";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Julia aqua";
        "scope" = "constant.language.julia";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Julia purple";
        "scope" = "support.function.macro.julia";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Elm white";
        "scope" = "keyword.other.period.elm";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Elm yellow";
        "scope" = "storage.type.elm";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "R orange";
        "scope" = "keyword.other.r";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "R green";
        "scope" = "entity.name.function.r, variable.function.r";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "R aqua";
        "scope" = "constant.language.r";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "R purple";
        "scope" = "entity.namespace.r";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Erlang grey";
        "scope" =
          "punctuation.separator.module-function.erlang, punctuation.section.directive.begin.erlang";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "Erlang red";
        "scope" = "keyword.control.directive.erlang, keyword.control.directive.define.erlang";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Erlang yellow";
        "scope" = "entity.name.type.class.module.erlang";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Erlang green";
        "scope" =
          "string.quoted.double.erlang, string.quoted.single.erlang, punctuation.definition.string.begin.erlang, punctuation.definition.string.end.erlang";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Erlang purple";
        "scope" =
          "keyword.control.directive.export.erlang, keyword.control.directive.module.erlang, keyword.control.directive.import.erlang, keyword.control.directive.behaviour.erlang";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Elixir aqua";
        "scope" = "variable.other.readwrite.module.elixir, punctuation.definition.variable.elixir";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Elixir blue";
        "scope" = "constant.language.elixir";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Elixir purple";
        "scope" = "keyword.control.module.elixir";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "OCaml white";
        "scope" = "entity.name.type.value-signature.ocaml";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "OCaml orange";
        "scope" = "keyword.other.ocaml";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "OCaml aqua";
        "scope" = "constant.language.variant.ocaml";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Perl red";
        "scope" = "storage.type.sub.perl, storage.type.declare.routine.perl";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Lisp white";
        "scope" = "meta.function.lisp";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Lisp red";
        "scope" = "storage.type.function-type.lisp";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Lisp green";
        "scope" = "keyword.constant.lisp";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Lisp aqua";
        "scope" = "entity.name.function.lisp";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Clojure green";
        "scope" = "constant.keyword.clojure, support.variable.clojure, meta.definition.variable.clojure";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Clojure purple";
        "scope" = "entity.global.clojure";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Clojure blue";
        "scope" = "entity.name.function.clojure";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Shell white";
        "scope" = "meta.scope.if-block.shell, meta.scope.group.shell";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "Shell yellow";
        "scope" = "support.function.builtin.shell, entity.name.function.shell";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Shell green";
        "scope" =
          "string.quoted.double.shell, string.quoted.single.shell, punctuation.definition.string.begin.shell, punctuation.definition.string.end.shell, string.unquoted.heredoc.shell";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Shell purple";
        "scope" =
          "keyword.control.heredoc-token.shell, variable.other.normal.shell, punctuation.definition.variable.shell, variable.other.special.shell, variable.other.positional.shell, variable.other.bracket.shell";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Fish red";
        "scope" = "support.function.builtin.fish";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Fish orange";
        "scope" = "support.function.unix.fish";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Fish blue";
        "scope" =
          "variable.other.normal.fish, punctuation.definition.variable.fish, variable.other.fixed.fish, variable.other.special.fish";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Fish green";
        "scope" =
          "string.quoted.double.fish, punctuation.definition.string.end.fish, punctuation.definition.string.begin.fish, string.quoted.single.fish";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Fish purple";
        "scope" = "constant.character.escape.single.fish";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "PowerShell grey";
        "scope" = "punctuation.definition.variable.powershell";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "PowerShell yellow";
        "scope" =
          "entity.name.function.powershell, support.function.attribute.powershell, support.function.powershell";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "PowerShell green";
        "scope" =
          "string.quoted.single.powershell, string.quoted.double.powershell, punctuation.definition.string.begin.powershell, punctuation.definition.string.end.powershell, string.quoted.double.heredoc.powershell";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "PowerShell aqua";
        "scope" = "variable.other.member.powershell";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "GraphQL white";
        "scope" = "string.unquoted.alias.graphql";
        "settings" = {
          "foreground" = "${colors.fg}";
        };
      }
      {
        "name" = "GraphQL red";
        "scope" = "keyword.type.graphql";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "GraphQL purple";
        "scope" = "entity.name.fragment.graphql";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Makefile orange";
        "scope" = "entity.name.function.target.makefile";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Makefile yellow";
        "scope" = "variable.other.makefile";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Makefile green";
        "scope" = "meta.scope.prerequisites.makefile";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "CMake green";
        "scope" = "string.source.cmake";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "CMake aqua";
        "scope" = "entity.source.cmake";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "CMake purple";
        "scope" = "storage.source.cmake";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "VimL grey";
        "scope" = "punctuation.definition.map.viml";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "VimL orange";
        "scope" = "storage.type.map.viml";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "VimL green";
        "scope" = "constant.character.map.viml, constant.character.map.key.viml";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "VimL blue";
        "scope" = "constant.character.map.special.viml";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Tmux green";
        "scope" = "constant.language.tmux, constant.numeric.tmux";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Dockerfile orange";
        "scope" = "entity.name.function.package-manager.dockerfile";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Dockerfile yellow";
        "scope" = "keyword.operator.flag.dockerfile";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Dockerfile green";
        "scope" = "string.quoted.double.dockerfile, string.quoted.single.dockerfile";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Dockerfile aqua";
        "scope" = "constant.character.escape.dockerfile";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "Dockerfile purple";
        "scope" = "entity.name.type.base-image.dockerfile, entity.name.image.dockerfile";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Diff grey";
        "scope" = "punctuation.definition.separator.diff";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "Diff red";
        "scope" = "markup.deleted.diff, punctuation.definition.deleted.diff";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Diff orange";
        "scope" = "meta.diff.range.context, punctuation.definition.range.diff";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Diff yellow";
        "scope" = "meta.diff.header.from-file";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "Diff green";
        "scope" = "markup.inserted.diff, punctuation.definition.inserted.diff";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Diff blue";
        "scope" = "markup.changed.diff, punctuation.definition.changed.diff";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "Diff purple";
        "scope" = "punctuation.definition.from-file.diff";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Git red";
        "scope" = "entity.name.section.group-title.ini, punctuation.definition.entity.ini";
        "settings" = {
          "foreground" = "${colors.coral}";
        };
      }
      {
        "name" = "Git orange";
        "scope" = "punctuation.separator.key-value.ini";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "Git green";
        "scope" =
          "string.quoted.double.ini, string.quoted.single.ini, punctuation.definition.string.begin.ini, punctuation.definition.string.end.ini";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "Git aqua";
        "scope" = "keyword.other.definition.ini";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "SQL yellow";
        "scope" = "support.function.aggregate.sql";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "SQL green";
        "scope" =
          "string.quoted.single.sql, punctuation.definition.string.end.sql, punctuation.definition.string.begin.sql, string.quoted.double.sql";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "GraphQL yellow";
        "scope" = "support.type.graphql";
        "settings" = {
          "foreground" = "${colors.gold}";
        };
      }
      {
        "name" = "GraphQL blue";
        "scope" = "variable.parameter.graphql";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "GraphQL aqua";
        "scope" = "constant.character.enum.graphql";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "JSON grey";
        "scope" =
          "punctuation.support.type.property-name.begin.json, punctuation.support.type.property-name.end.json, punctuation.separator.dictionary.key-value.json, punctuation.definition.string.begin.json, punctuation.definition.string.end.json, punctuation.separator.dictionary.pair.json, punctuation.separator.array.json";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "JSON orange";
        "scope" = "support.type.property-name.json";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "JSON green";
        "scope" = "string.quoted.double.json";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "YAML grey";
        "scope" = "punctuation.separator.key-value.mapping.yaml";
        "settings" = {
          "foreground" = "#8b938d";
        };
      }
      {
        "name" = "YAML green";
        "scope" =
          "string.unquoted.plain.out.yaml, string.quoted.single.yaml, string.quoted.double.yaml, punctuation.definition.string.begin.yaml, punctuation.definition.string.end.yaml, string.unquoted.plain.in.yaml, string.unquoted.block.yaml";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "YAML aqua";
        "scope" = "punctuation.definition.anchor.yaml, punctuation.definition.block.sequence.item.yaml";
        "settings" = {
          "foreground" = "${colors.c6}";
        };
      }
      {
        "name" = "TOML orange";
        "scope" = "keyword.key.toml";
        "settings" = {
          "foreground" = "${colors.apricot}";
        };
      }
      {
        "name" = "TOML green";
        "scope" =
          "string.quoted.single.basic.line.toml, string.quoted.single.literal.line.toml, punctuation.definition.keyValuePair.toml";
        "settings" = {
          "foreground" = "${colors.accent}";
        };
      }
      {
        "name" = "TOML blue";
        "scope" = "constant.other.boolean.toml";
        "settings" = {
          "foreground" = "${colors.accent2}";
        };
      }
      {
        "name" = "TOML purple";
        "scope" =
          "entity.other.attribute-name.table.toml, punctuation.definition.table.toml, entity.other.attribute-name.table.array.toml, punctuation.definition.table.array.toml";
        "settings" = {
          "foreground" = "${colors.c5}";
        };
      }
      {
        "name" = "Comment";
        "scope" = "comment, string.comment, punctuation.definition.comment";
        "settings" = {
          "foreground" = "#8b938d";
          "fontStyle" = "italic";
        };
      }
    ];
  };

  semanticTokenColorCustomizations = {
    enabled = true;
    rules = {
      "operatorOverload" = "${colors.apricot}";
      "memberOperatorOverload" = "${colors.apricot}";
      "variable.defaultLibrary:javascript" = "${colors.c5}";
      "property.defaultLibrary:javascript" = "${colors.c5}";
      "variable.defaultLibrary:javascriptreact" = "${colors.c5}";
      "property.defaultLibrary:javascriptreact" = "${colors.c5}";
      "class:typescript" = "${colors.c6}";
      "interface:typescript" = "${colors.c6}";
      "enum:typescript" = "${colors.c5}";
      "enumMember:typescript" = "${colors.accent2}";
      "namespace:typescript" = "${colors.c5}";
      "variable.defaultLibrary:typescript" = "${colors.c5}";
      "property.defaultLibrary:typescript" = "${colors.c5}";
      "class:typescriptreact" = "${colors.c6}";
      "interface:typescriptreact" = "${colors.c6}";
      "enum:typescriptreact" = "${colors.c5}";
      "enumMember:typescriptreact" = "${colors.accent2}";
      "namespace:typescriptreact" = "${colors.c5}";
      "variable.defaultLibrary:typescriptreact" = "${colors.c5}";
      "property.defaultLibrary:typescriptreact" = "${colors.c5}";
      "intrinsic:python" = "${colors.c5}";
      "module:python" = "${colors.accent2}";
      "class:python" = "${colors.c6}";
      "macro:rust" = "${colors.c6}";
      "namespace:rust" = "${colors.c5}";
      "selfKeyword:rust" = "${colors.c5}";
    };
  };
}
