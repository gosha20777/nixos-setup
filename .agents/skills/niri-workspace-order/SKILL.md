---
name: niri-workspace-order
description: Restoring named workspace order in niri when the workspace stack gets reversed or scrambled after a config reload. Covers the upstream cause (insert-at-bottom in ensure_named_workspace), diagnosis via niri msg, and the focus-then-move IPC procedure. Use when workspaces in the Noctalia bar or niri overview appear out of their declared order.
---

# Niri Workspace Order Restoration Skill

Use this skill when the workspace order in the Noctalia bar (or niri overview) does not
match the order declared in `modules/home/desktop/niri.nix` — e.g. after renaming
workspaces, the bar shows them reversed or scrambled.

---

## 1. Root Cause (upstream niri behavior)

Named workspaces are declared in `modules/home/desktop/niri.nix`:

```nix
workspaces = {
  "01-web".name = "󰖟 Web";
  "02-dev".name = "󰅩 Dev";
  "03-game".name = "󰊴 Game";
};
```

Two creation paths in niri (`src/layout/mod.rs`) behave differently:

- **Fresh session start** (`with_options_and_workspaces`): workspaces are created in
  config declaration order (Web, Dev, Game). Correct.
- **Config reload with renamed workspaces** (`ensure_named_workspace`): each *new*
  workspace is inserted at the BOTTOM of the stack (`workspaces.insert(0, ws)` /
  `mon.workspaces.insert(insert_idx, ws)` with `insert_idx = 0`). When names change
  (emoji → Nerd Font glyphs, any rename), niri treats them as new workspaces: the old
  ones close, the new ones insert one-by-one at the bottom — **the stack ends up
  reversed** relative to the config.

Workspace order is **runtime state**, not config: niri persists the current stack
per-session; the config only influences it at creation time. Noctalia's bar follows
the live stack (ext-workspace protocol sorts by coordinates), so it honestly reflects
whatever niri currently has.

Trigger conditions for a scrambled stack:
- Renaming workspaces in `niri.nix` and reloading the session (`nh os switch`).
- Manually moving workspaces with keyboard binds.
- Order survives normal reloads; it breaks only when workspace *names* change.

---

## 2. Diagnosis

Read the live stack (idx ascending = bottom-to-top):

```bash
niri msg --json workspaces | python3 -c "
import json,sys
for w in sorted(json.load(sys.stdin), key=lambda w: w['idx']):
    print(w['idx'], repr(w.get('name')), 'active' if (w.get('is_active') or w.get('isActive') or w.get('active')) else '')"
```

Compare against the declared order in `modules/home/desktop/niri.nix`
(01-web → 02-dev → 03-game → Web, Dev, Game). Names there contain Nerd Font
glyphs, which `repr()` shows as `\U000f059f` etc. — that is expected.

Expected healthy state:
```
1 '󰖟 Web'
2 '󰅩 Dev'
3 '󰊴 Game'
4 None          ← auto-created empty workspace, always present, harmless
```

---

## 3. Restoration procedure

`niri msg action move-workspace-to-index <N>` moves the **active** workspace to
position N (1-based). It does NOT accept a workspace id. Therefore the procedure is:
focus the misplaced workspace, then move it to its target index. One step at a time,
re-checking the stack after each move.

```bash
niri msg action focus-workspace <current-idx-of-misplaced-ws>
sleep 0.2   # let niri settle the active-workspace switch
niri msg action move-workspace-to-index <target-idx>
```

Repeat focus+move per workspace until the stack matches the config, verifying with
the diagnosis command after every move.

Worked example (stack was Game=1, Web=2, Dev=3; target Web=1, Dev=2, Game=3):

```bash
# Move Game out of the way to the bottom
niri msg action focus-workspace 1      # Game is active
niri msg action move-workspace-to-index 3   # stack: Web, Dev, Game? verify!

# After each move RE-READ the stack and recompute which idx holds what.
# Continue focus+move until:
#   1='󰖟 Web'  2='󰅩 Dev'  3='󰊴 Game'
```

Key gotchas:
- `focus-workspace <N>` refers to the **current** position index, not the target —
  re-run the diagnosis command after every single move.
- A `move-workspace-to-index` on a workspace that is already at that index is a
  no-op — harmless, useful for confirming positions.
- The empty unnamed workspace at the bottom (highest idx) is normal; never try to
  "fix" it into the middle.
- If a move seems to have no effect, the wrong workspace was active — the action
  silently operates on `active_workspace_idx`. Always focus first, then move.

---

## 4. Alternative fixes (when to prefer them)

- **Full session restart** (logout/login or reboot): niri recreates named workspaces
  in config order. Cleanest fix when a logout is acceptable; no manual reordering.
- **Prevention:** avoid renaming workspace `name` values across reloads. Changing
  key order (`01-web`/`02-dev`/`03-game` prefixes) is safe — names are what identify
  workspaces to niri.
- Upstream fix (insert respecting config order in `ensure_named_workspace`) would
  remove the need for this skill entirely; until then this is the workaround.

---

## 5. Verification

After restoration, all three must hold:

1. Diagnosis command output matches the declared config order
   (`1='Web' 2='Dev' 3='Game'` + trailing empty).
2. Noctalia bar shows workspaces in the same left-to-right order (the bar follows
   the live stack; no restart of noctalia needed — it re-reads on WorkspacesChanged).
3. `open-on-workspace` rules in `modules/home/desktop/niri.nix` match by **name**,
   so window placement is unaffected by index changes — no action needed there.
