---
name: display-scaling
description: Calculate optimal display and UI scaling factors (niri output scale, GNOME text-scaling-factor) based on monitor geometry, resolution, distance, and user visual acuity (0.3 decimal, MAR 3.333 arcmin / 0.05556 degrees).
---

# Display Scaling Skill

Use this skill when configuring display resolutions, text scaling, or window manager output scales (e.g. Niri, Hyprland, GNOME, Sway) for this user.

## User Biometric Profile

- **Visual Acuity**: `0.3` (decimal, corrected with glasses)
- **Refraction**: `-7.0 D` (high myopia)
- **MAR (Minimum Angle of Resolution)**:
  - In arcminutes: `3.333'` ($1 / 0.3$)
  - In degrees: `0.05556°`
- **Threshold Optotype Letter**: `16.67'` ($0.2778°$)
- **Default Viewing Distance**: `50 cm` (`500 mm`) — forearm/elbow distance
- **Target Comfort Band**: `4.0x ... 6.0x MAR` ($13.3' \dots 20.0'$ x-height), ideally `5.5x ... 5.6x MAR` (~`18.7'`).

## Calculation Formula

Given:
- $W, H$: display resolution in pixels
- $Diag$: display diagonal in inches
- $D$: viewing distance in mm (default 500 mm)

$$\text{PPI} = \frac{\sqrt{W^2 + H^2}}{Diag}$$
$$\text{pitch}_{mm} = \frac{25.4}{\text{PPI}}$$
$$\text{pxPerArcmin} = \frac{D \times 2.908882 \times 10^{-4} \times \text{PPI}}{25.4}$$
$$\theta_{x, base} = \frac{7.627}{\text{pxPerArcmin}} \quad (\text{for standard 11pt UI font})$$
$$\text{Optimal Scale } S = \frac{5.6 \times 3.333}{\theta_{x, base}} = \frac{18.67}{\theta_{x, base}}$$

## Reference Configuration

- **NixOS Niri** (`hosts/<host>/home.nix`):
  ```nix
  programs.niri.settings.outputs."<Output-Name>".scale = 1.3;
  ```
- **GNOME** (`text-scaling-factor`):
  ```bash
  gsettings set org.gnome.desktop.interface text-scaling-factor 1.30
  ```

Full detailed methodology and proofs: see `display-scaling.md` in repository root.
