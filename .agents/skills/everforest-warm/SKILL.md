---
name: everforest-warm
description: Implement, port, and adapt the high-contrast Everforest Warm design system across any application (VS Code, GUI apps, terminals, web, editors) with strict semantic fidelity, eye-fatigue prevention, mathematical contrast benchmarks, and NixOS module isolation.
---

# Everforest Warm Theming Skill

Use this skill when implementing, extending, porting, or auditing themes for any application in this personal NixOS configuration. It guarantees complete visual harmony, zero eye fatigue, high contrast, and architectural modularity across all desktop and CLI tools.

---

## 1. Design & Ergonomics Philosophy

The Everforest Warm theme is engineered for developers with high visual demands and prolonged screen sessions. Its core ergonomics principles are:

1. **Ergonomic Base (No Pure Black `#000000`):**
   - Pure black causes extreme pupillary constriction when shifting gaze between text and background, leading to ocular muscle strain and severe halation (glow around characters) on OLED and IPS displays.
   - The canonical background `#141617` ($L \approx 8.4\%$) provides an ultra-deep, warm charcoal base with a pine undertone, mimicking premium matte dark paper.
2. **Botanical Spectrum (Zero Neon Fatigue):**
   - Standard neon RGB primaries (e.g. `#FF0000`, `#00FF00`, `#0000FF`) produce photopic glare and chromatic aberration in human lenses.
   - Accents are drawn from natural earth and botanical tones: wild sage, warm pine wave, golden amber, apricot, coral red, and heather berry.
3. **Balanced Energy Distribution:**
   - Syntax tokens share a balanced relative luminance envelope ($L \approx 53\%\dots69\%$). No single token flashes or overpowers surrounding code, preventing constant refocusing of the eye.
4. **Resolution of the Classic Everforest Muddiness:**
   - Original Everforest suffers from low color saturation ($\approx 30\dots33\%$) and low contrast ($4.5:1\dots5.0:1$), causing characters to appear blurry or "foggy" on non-retina displays.
   - Everforest Warm increases accent saturation by $+10\%\dots+17\%$ and sharpens hue separation between green, aqua, and blue, making symbols instantly differentiable without sacrificing warmth.

---

## 2. Canonical Everforest Warm Palette Table

This table is the **absolute single source of truth** for all Everforest Warm adaptations (derived from the official Everforest architecture updated with our calibrated warm high-contrast values):

### Core Syntax & Semantic Accents

| Token Name | Hex | RGB | HSL | Semantic Syntax Role |
| :--- | :--- | :--- | :--- | :--- |
| **Foreground (`fg`)** | `#E1DACB` | `rgb(225, 218, 203)` | `40.9°, 26.8%, 83.9%` | Default text, variables, identifiers, parameters |
| **Red** | `#F26E74` | `rgb(242, 110, 116)` | `357.3°, 83.5%, 69.0%` | Keywords, storage modifiers, control flow, Git delete |
| **Orange** | `#F2874B` | `rgb(242, 135, 75)` | `21.6°, 86.5%, 62.2%` | Constants, numbers, booleans, operators |
| **Yellow** | `#E2B862` | `rgb(226, 184, 98)` | `40.3°, 68.8%, 63.5%` | Strings, attributes, template literals |
| **Green** | `#9EC468` | `rgb(158, 196, 104)` | `84.8°, 43.8%, 58.8%` | Functions, methods, calls, Git additions, status ok |
| **Aqua** | `#52BFA3` | `rgb(82, 191, 163)` | `164.6°, 46.0%, 53.5%` | Modules, namespaces, properties, regex, preprocessor |
| **Blue** | `#65B8C7` | `rgb(101, 184, 199)` | `189.2°, 46.7%, 58.8%` | Types, classes, interfaces, structs, primitives |
| **Purple** | `#D67B9D` | `rgb(214, 123, 157)` | `337.6°, 52.6%, 66.1%` | Decorators, macros, enums, special operators |

### Bright / Highlight Spectrum (ANSI Bright / Secondary Accents)

| Token Name | Hex | RGB | HSL | UI / Syntax Role |
| :--- | :--- | :--- | :--- | :--- |
| **Bright Red** | `#F2874B` | `rgb(242, 135, 75)` | `21.6°, 86.5%, 62.2%` | Prominent warnings, breaking changes |
| **Bright Green** | `#AFD874` | `rgb(175, 216, 116)` | `84.6°, 57.5%, 65.1%` | Function definitions, active indicators |
| **Bright Yellow** | `#F3C775` | `rgb(243, 199, 117)` | `39.0°, 84.0%, 70.6%` | Search match highlight, focused strings |
| **Bright Blue** | `#7BC9D8` | `rgb(123, 201, 216)` | `189.7°, 55.4%, 66.5%` | URL links, generic type arguments |
| **Bright Purple** | `#E592B1` | `rgb(229, 146, 177)` | `337.6°, 63.8%, 73.5%` | Special keywords (`this`, `super`, `self`) |
| **Bright Aqua** | `#69D3B7` | `rgb(105, 211, 183)` | `164.2°, 56.4%, 62.0%` | Inline documentation tags, regex groups |
| **Bright White** | `#F7F4EC` | `rgb(247, 244, 236)` | `43.6°, 42.9%, 94.7%` | Maximum emphasis, bold headers, selection fg |

### Background Hierarchy & Surface Layers

| Token Name | Hex | RGB | HSL | Surface Mapping |
| :--- | :--- | :--- | :--- | :--- |
| **Background Dim** | `#101112` | `rgb(16, 17, 18)` | `210.0°, 5.9%, 6.7%` | Dropdown shadow, lowest canvas, inactive modals |
| **Background 0 (`bg`)**| `#141617` | `rgb(20, 22, 23)` | `200.0°, 7.0%, 8.4%` | Editor canvas, terminal background, main window |
| **Background 1** | `#1A1D1F` | `rgb(26, 29, 31)` | `204.0°, 8.8%, 11.2%` | Sidebar, activity bar, terminal tab bar, statusbar |
| **Background 2 (`c0`)**| `#262B2E` | `rgb(38, 43, 46)` | `202.5°, 9.5%, 16.5%` | Toolbars, panel headers, list hover, alternating rows |
| **Background 3** | `#282D30` | `rgb(40, 45, 48)` | `202.5°, 9.1%, 17.3%` | Inactive borders, input backgrounds, gutter |
| **Background 4 (`surfaceSelect`)**| `#2C3C40`| `rgb(44, 60, 64)` | `192.0°, 18.5%, 21.2%`| Active list item, cursor line, subtle panel hover |
| **Background 5** | `#374246` | `rgb(55, 66, 70)` | `196.0°, 12.0%, 24.5%`| Active borders, search result markers, badges |

### Muted Elements & Grayscale

| Token Name | Hex | RGB | HSL | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Grey 0 (`smoke`)** | `#828C85` | `rgb(130, 140, 133)` | `138.0°, 4.2%, 52.9%` | Code comments, docstrings, hidden files |
| **Grey 1** | `#8B938D` | `rgb(139, 147, 141)` | `135.0°, 3.6%, 56.1%` | Inactive tabs, line numbers, subtle icons |
| **Grey 2** | `#A5ADA7` | `rgb(165, 173, 167)` | `135.0°, 5.1%, 66.3%` | Disabled buttons, parameter hints, placeholders |

### Semantic Background Tints (Diffs, Diagnostics, Badges)

| Token Name | Hex (Solid) | Hex (Alpha) | UI Usage |
| :--- | :--- | :--- | :--- |
| **Background Red** | `#362426` | `#F26E7430` | Git deleted line, error banner, lint error |
| **Background Orange** | `#362B22` | `#F2874B30` | Git modified line, warning banner |
| **Background Yellow** | `#362F22` | `#E2B86230` | Search match, lint warning |
| **Background Green** | `#263625` | `#9EC46830` | Git inserted line, test success |
| **Background Blue** | `#21353B` | `#65B8C730` | Information block, debug watch variable |
| **Background Purple** | `#35252F` | `#D67B9D30` | Snippet placeholder, selection highlight |

---

## 3. Readability & Contrast Metrics Calculation

All ported colors must be rigorously tested against the background using the WCAG 2.1 relative luminance and contrast ratio algorithms.

### Mathematical Formulation

1. **Normalized Channel Linearization ($C_{lin}$):**
   For each sRGB component $C \in \{R, G, B\} \in [0, 255]$, let $c = C / 255$:
   $$c_{lin} = \begin{cases} \frac{c}{12.92}, & \text{if } c \le 0.03928 \\ \left(\frac{c + 0.055}{1.055}\right)^{2.4}, & \text{if } c > 0.03928 \end{cases}$$

2. **Relative Luminance ($L$):**
   $$L = 0.2126 \cdot r_{lin} + 0.7152 \cdot g_{lin} + 0.0722 \cdot b_{lin}$$

3. **Contrast Ratio ($CR$):**
   Given two colors with relative luminances $L_1$ and $L_2$ where $L_1 \ge L_2$:
   $$CR = \frac{L_1 + 0.05}{L_2 + 0.05} : 1$$

### Benchmark Targets for Everforest Warm

| Element Type | Target Range | Strict Floor | Everforest Warm Actual | Status |
| :--- | :---: | :---: | :---: | :---: |
| **Primary Text (`fg` on `bg`)** | $12.0:1 \dots 14.0:1$ | $\ge 10.0:1$ | **$13.05:1$** | Exceeds WCAG AAA ($7:1$) |
| **Syntax Accents (Average)** | $6.5:1 \dots 10.0:1$ | $\ge 5.5:1$ | **$6.2:1 \dots 9.7:1$** | Clear differentiation |
| **Comments (`grey0` on `bg`)** | $5.0:1 \dots 6.0:1$ | $\ge 4.5:1$ | **$5.51:1$** | Readable, non-distracting |
| **UI Borders (`bg3` on `bg`)** | $1.5:1 \dots 2.2:1$ | $\ge 1.3:1$ | **$1.85:1$** | Crisp spatial bounding |
| **Text Selection (Sage Inversion)** | $\ge 7.0:1$ | $\ge 7.0:1$ | **$9.12:1$** (`#9EC468` / `#141617`) | Exceeds WCAG AAA ($7:1$) |

### Python Script for Metric Verification

```python
def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def rel_luminance(r, g, b):
    def channel(c):
        c = c / 255.0
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)

def contrast_ratio(hex1, hex2):
    lum1 = rel_luminance(*hex_to_rgb(hex1))
    lum2 = rel_luminance(*hex_to_rgb(hex2))
    return round((max(lum1, lum2) + 0.05) / (min(lum1, lum2) + 0.05), 2)

# Verification
bg = "#141617"
fg = "#E1DACB"
print(f"Primary contrast: {contrast_ratio(fg, bg)}:1")  # Must be >= 12.0
```

---

## 4. Rules for Forking Existing Everforest Themes

When an upstream theme already exists for a target application (e.g. `everforest-vscode`, vim-everforest, everforest-gtk), follow these mandatory transformation rules:

1. **Target the `dark-hard` Variant as the Base:**
   - Always fork from the `dark-hard` (or `hard`) configuration. Never fork from `soft` or `medium` — `hard` has the closest structural layering to our deep-canvas design.
2. **Rule of Differential Preservation:**
   - **If two elements had different colors in the original theme, they MUST remain differently colored in Everforest Warm.**
   - Never collapse distinct syntactic tokens into a single accent. (e.g., if keywords and function calls were distinct colors, do not map both to green or both to yellow).
3. **Rule of Semantic Chromatic Fidelity:**
   - **If an element was green, it MUST remain green.**
   - Maintain the semantic identity of every hue:
     - Original Green $\to$ Warm Sage (`#9EC468`) or Bright Green (`#AFD874`).
     - Original Yellow $\to$ Warm Amber (`#E2B862`).
     - Original Orange $\to$ Warm Apricot (`#F2874B`).
     - Original Red $\to$ Warm Coral (`#F26E74`).
     - Original Blue $\to$ Warm Pine (`#65B8C7`).
     - Original Aqua $\to$ Warm Mint (`#52BFA3`).
     - Original Purple $\to$ Warm Berry (`#D67B9D`).
4. **Resolution of the Green-Aqua-Blue Cluster:**
   - In upstream Everforest Dark, Green ($83^\circ$), Aqua ($135^\circ$), and Blue ($172^\circ$) often merge into an indistinguishable grey-green soup.
   - You MUST enforce our distinct hues:
     - **Green** at $84.8^\circ$ (warm sage) $\to$ Functions and active states.
     - **Aqua** shifted to $164.6^\circ$ (clean emerald mint) $\to$ Properties and modules.
     - **Blue** shifted to $189.2^\circ$ (pacific pine) $\to$ Types and classes.
5. **Elevating Contrast and Stripping the Fog:**
   - Replace the upstream background (`#272E33` or `#1B2024`) with `#141617`.
   - Upgrade foreground from `#D3C6AA` to `#E1DACB` ($CR$ jumps from $8.2:1 \to 13.1:1$).
   - Increase saturation across all syntax accents by $+10\%\dots+17\%$ to counteract the muddy appearance.

---

## 5. Architectural Pattern in NixOS

Every theme port in this repository follows the strict isolation and single-source-of-truth pattern:

### Directory & File Hierarchy

```
modules/
├── themes/
│   └── everforest-warm/
│       ├── default.nix      # Central registry: exports `colors`, `noctalia`, per-app themes
│       ├── yazi.nix         # Yazi theme configuration
│       ├── vscode.nix       # VS Code theme configuration
│       ├── telegram.nix     # Telegram theme configuration
│       └── <app>.nix        # Isolated per-application theme
└── home/
    ├── dev/
    │   └── vscode.nix       # Application home-manager module (consumes theme.vscode)
    └── cli/
        └── yazi.nix         # Application home-manager module (consumes theme.yazi)
```

### The Isolated Theme Module Pattern (`modules/themes/everforest-warm/<app>.nix`)

Theme files inside `modules/themes/everforest-warm/` must contain **only styling logic** and import base colors directly from `./default.nix`:

```nix
# modules/themes/everforest-warm/<app>.nix
let
  inherit ((import ./default.nix)) colors;
in
{
  # Application-specific color definitions using `colors.*`
  editor.background = colors.bg;
  editor.foreground = colors.fg;
  accent = colors.accent;
}
```

### The Central Exporter (`modules/themes/everforest-warm/default.nix`)

Expose the new theme module as an attribute in `default.nix`:

```nix
rec {
  colors = { ... };
  noctalia = { ... };
  yazi = import ./yazi.nix;
  vscode = import ./vscode.nix;
  # <app> = import ./<app>.nix;
}
```

### The Application Consumer (`modules/home/<category>/<app>.nix`)

The application module in `modules/home/` imports the theme dynamically based on `systemSettings.theme`:

```nix
{ config, pkgs, systemSettings, ... }:
let
  theme = import ../../themes/${systemSettings.theme};
in
{
  programs.<app> = {
    enable = true;
    # Pass theme.<app> into the program's configuration
  };
}
```

---

## 6. System-Wide UI Consistency (Controls, Buttons & Widgets)

To ensure cohesive behavior across GTK, Qt, Noctalia (Quickshell), and custom apps, interactive widgets must adhere to these unified tokens:

| Widget / Control | State | Token | Hex | Text / Foreground |
| :--- | :--- | :--- | :--- | :--- |
| **Text Selection** | Selected | `colors.selectionBg` (Sage) | `#9EC468` | `colors.selectionFg` (`#141617`) |
| **Primary Button** | Default | `colors.accent` (Sage) | `#9EC468` | `colors.bg` (`#141617`) |
| **Primary Button** | Hover | `colors.c10` (Bright Sage) | `#AFD874` | `colors.bg` (`#141617`) |
| **Secondary Button** | Default | `colors.surfaceDark` | `#282D30` | `colors.fg` (`#E1DACB`) |
| **Secondary Button** | Hover | `colors.selectionBg` | `#2C3C40` | `colors.fg` (`#E1DACB`) |
| **Radio Button / Checkbox** | Checked | `colors.accent` | `#9EC468` | `colors.bg` (`#141617`) |
| **Radio Button / Checkbox** | Unchecked | `colors.surfaceDark` | `#282D30` | Border: `#374246` |
| **Input Field** | Default | `colors.bg` | `#141617` | Border: `#282D30`, Text: `#E1DACB` |
| **Input Field** | Focused | `colors.bg` | `#141617` | Border: `#9EC468`, Text: `#E1DACB` |
| **Active Tab / Header** | Active | `colors.bg` | `#141617` | Line/Accent: `#9EC468`, Text: `#E1DACB` |
| **Inactive Tab** | Inactive | `colors.c0` | `#262B2E` | Text: `#8B938D` |
| **Badge / Notification** | Default | `colors.accent` | `#9EC468` | Text: `#141617` |
| **Danger / Destructive** | Default | `colors.coral` | `#F26E74` | Text: `#141617` |

---

## 7. Theming Protocol for Applications without an Upstream Theme

When theming an application from scratch (no Everforest port exists):

1. **Step 1: Identify Color Slots:** Determine the application's theming capability (JSON schema, CSS/QSS, INI, TOML, or CLI flags).
2. **Step 2: Map Surface Depths:**
   - Main reading/editing canvas $\to$ `colors.bg` (`#141617`).
   - Sidebars/Navigation panels $\to$ Background 1 (`#1A1D1F`).
   - Toolbars & Header bars $\to$ `colors.c0` (`#262B2E`).
   - Hovered rows & selections $\to$ `colors.selectionBg` (`#2C3C40`).
3. **Step 3: Map Accents via the Semantic Table:**
   - Functions/Actions $\to$ Sage (`#9EC468`).
   - Primary Identifiers/Types $\to$ Pine (`#65B8C7`).
   - Literals/Numbers $\to$ Apricot (`#F2874B`).
   - Strings $\to$ Gold Amber (`#E2B862`).
   - Keywords/Alerts $\to$ Coral (`#F26E74`).
4. **Step 4: Check Contrast Ratios:**
   - Execute the verification formula ensuring text contrast $\ge 12:1$ and syntax contrast $\ge 5.5:1$.
5. **Step 5: Isolate in Nix:**
   - Add `modules/themes/everforest-warm/<app>.nix` and wire through `systemSettings.theme`.
